"""
Collect comprehensive metrics for the BD-Risk validation paper.

Outputs JSON with precision/recall/F1, Spearman correlation, UNCERTAIN
analysis, and confusion matrices — all computed from the BD-Risk SQLite
database for a specific (prompt_version, subset) combination.

The paper reports numbers from the held-out subset under the current
prompt version (`improved_v6`), and those are the script's defaults.

This script depends on the engineering repo (`src.database.models`,
`src.config`). Since the thesis repo is now separated, point at the
engineering checkout with the ``MOODTRAIL_REPO`` env var (sibling
default: ``../reddit`` relative to this thesis repo).

Usage:
    # Defaults (paper numbers: held-out × improved_v6)
    MOODTRAIL_REPO=../reddit python scripts/collect_paper_metrics.py

    # Override the subset
    python scripts/collect_paper_metrics.py --subset tuning
"""

import argparse
import json
import sys
import os

# Make the engineering repo importable. The thesis repo no longer
# contains the src/ tree, so allow the user to point at the engineering
# checkout via env var; default to a sibling directory called `reddit`
# (the layout when both repos live under research/).
_THESIS_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_ENG_REPO = os.environ.get(
    'MOODTRAIL_REPO',
    os.path.abspath(os.path.join(_THESIS_ROOT, '..', 'reddit')),
)
if _ENG_REPO not in sys.path:
    sys.path.insert(0, _ENG_REPO)

from collections import Counter
import numpy as np
from scipy.stats import spearmanr, pearsonr
from sklearn.metrics import (
    classification_report,
    cohen_kappa_score,
    confusion_matrix,
    f1_score,
    precision_score,
    recall_score,
)

from src import config
from src.database.models import AnalysisRecord, Submission
from src.database.bd_risk_models import ExpertLabel, MOOD_TO_STATE, init_bd_risk_db


STATES = ["DEPRESSIVE", "STABLE", "HYPOMANIC", "MANIC"]
MOOD_LABELS = [-3, -2, -1, 0, 1, 2, 3]


def extract_pairs(prompt_version=None, subset=None, model_version=None):
    """Extract (expert, LLM) label pairs from the BD-Risk database.

    Args:
        prompt_version: filter to this `AnalysisRecord.prompt_version`
            (e.g. "improved_v6"). None means no filter.
        subset: filter to this `ExpertLabel.evaluation_subset`
            ("tuning" or "holdout"). None means no filter (both subsets).
        model_version: filter to this `AnalysisRecord.model_version`.
            None means no filter.
    """
    init_bd_risk_db(config.DB_RISK_DB_FILE)

    query = (
        AnalysisRecord
        .select()
        .where(
            AnalysisRecord.strategy == "single",
            AnalysisRecord.is_outdated == False,
        )
    )
    if prompt_version is not None:
        query = query.where(AnalysisRecord.prompt_version == prompt_version)
    if model_version is not None:
        query = query.where(AnalysisRecord.model_version == model_version)

    pairs = []
    for record in query:
        llm_result = record.llm_result
        if not llm_result:
            continue

        target = record.targets.first()
        if not target:
            continue

        try:
            sub = Submission.get(Submission.reddit_id == target.reddit_id)
            el = ExpertLabel.get(ExpertLabel.submission == sub)
        except Exception:
            continue

        expert_state = MOOD_TO_STATE.get(el.paper_mood)
        if not expert_state:
            continue

        if subset is not None and getattr(el, "evaluation_subset", None) != subset:
            continue

        pairs.append({
            "reddit_id": sub.reddit_id,
            "expert_mood": el.paper_mood,
            "expert_state": expert_state,
            "llm_state": llm_result.get("state"),
            "llm_mood": llm_result.get("mood_label"),
            "llm_confidence": llm_result.get("confidence", ""),
            "llm_specifiers": llm_result.get("specifiers", []),
            "shift_label": el.shift_label,  # 0=MDD, 1=MDD->BD
        })

    return pairs


def state_metrics(pairs):
    """Compute state-level classification metrics (excluding UNCERTAIN)."""
    # Filter to pairs where LLM produced a known state
    valid = [p for p in pairs if p["llm_state"] in STATES]
    all_with_uncertain = [p for p in pairs if p["llm_state"]]

    y_true = [p["expert_state"] for p in valid]
    y_pred = [p["llm_state"] for p in valid]

    report = classification_report(y_true, y_pred, labels=STATES, output_dict=True, zero_division=0)

    cm = confusion_matrix(y_true, y_pred, labels=STATES)
    cm_with_unc = None

    all_labels = STATES + ["UNCERTAIN"]
    y_true_all = [p["expert_state"] for p in all_with_uncertain]
    y_pred_all = [p["llm_state"] for p in all_with_uncertain]
    cm_with_unc = confusion_matrix(y_true_all, y_pred_all, labels=all_labels)

    kappa = cohen_kappa_score(y_true, y_pred, labels=STATES)
    kappa_linear = cohen_kappa_score(
        [STATES.index(s) for s in y_true],
        [STATES.index(s) for s in y_pred],
        weights="linear",
    )

    overall_acc = sum(1 for a, b in zip(y_true, y_pred) if a == b) / len(y_true) if y_true else 0
    overall_acc_with_unc = (
        sum(1 for a, b in zip(y_true_all, y_pred_all) if a == b) / len(y_true_all)
        if y_true_all else 0
    )

    per_state = {}
    for st in STATES:
        st_data = report.get(st, {})
        per_state[st] = {
            "precision": round(st_data.get("precision", 0), 4),
            "recall": round(st_data.get("recall", 0), 4),
            "f1": round(st_data.get("f1-score", 0), 4),
            "support": st_data.get("support", 0),
        }

    return {
        "total_pairs": len(pairs),
        "valid_pairs_excl_uncertain": len(valid),
        "uncertain_count": sum(1 for p in pairs if p["llm_state"] == "UNCERTAIN"),
        "overall_accuracy_excl_uncertain": round(overall_acc, 4),
        "overall_accuracy_incl_uncertain": round(overall_acc_with_unc, 4),
        "macro_f1": round(report["macro avg"]["f1-score"], 4),
        "weighted_f1": round(report["weighted avg"]["f1-score"], 4),
        "macro_precision": round(report["macro avg"]["precision"], 4),
        "macro_recall": round(report["macro avg"]["recall"], 4),
        "cohens_kappa": round(kappa, 4),
        "cohens_kappa_linear_weighted": round(kappa_linear, 4),
        "per_state": per_state,
        "confusion_matrix_labels": STATES,
        "confusion_matrix": cm.tolist(),
        "confusion_matrix_with_uncertain_labels": all_labels,
        "confusion_matrix_with_uncertain": cm_with_unc.tolist() if cm_with_unc is not None else None,
    }


def mood_metrics(pairs):
    """Compute mood-label-level metrics (7-point ordinal scale).

    Returns None when no LLM record carries `llm_mood` (current prompt
    versions omit the mood_label field by design), so the caller can
    distinguish "metric not applicable" from "metric is zero".
    """
    valid = [p for p in pairs if isinstance(p["llm_mood"], int)]
    if not valid:
        return None

    y_true = np.array([p["expert_mood"] for p in valid])
    y_pred = np.array([p["llm_mood"] for p in valid])

    exact_match = int(np.sum(y_true == y_pred))
    within_one = int(np.sum(np.abs(y_true - y_pred) <= 1))
    diffs = y_pred - y_true
    mae = float(np.mean(np.abs(diffs)))
    mean_bias = float(np.mean(diffs))
    rmse = float(np.sqrt(np.mean(diffs ** 2)))

    spearman_r, spearman_p = spearmanr(y_true, y_pred)
    pearson_r, pearson_p = pearsonr(y_true, y_pred)

    kappa_qw = cohen_kappa_score(y_true, y_pred, weights="quadratic")
    kappa_lw = cohen_kappa_score(y_true, y_pred, weights="linear")

    cm = confusion_matrix(y_true, y_pred, labels=MOOD_LABELS)

    per_label = {}
    for label in MOOD_LABELS:
        mask_true = y_true == label
        n = int(np.sum(mask_true))
        if n == 0:
            per_label[str(label)] = {"exact": 0, "within_one": 0, "total": 0, "exact_acc": 0}
            continue
        exact = int(np.sum((y_true == label) & (y_pred == label)))
        w1 = int(np.sum(mask_true & (np.abs(y_pred - label) <= 1)))
        per_label[str(label)] = {
            "exact": exact,
            "within_one": w1,
            "total": n,
            "exact_acc": round(exact / n, 4),
            "within_one_acc": round(w1 / n, 4),
        }

    # Negative vs positive pole accuracy
    neg_mask = y_true < 0
    pos_mask = y_true > 0
    zero_mask = y_true == 0
    neg_w1_acc = float(np.mean(np.abs(y_pred[neg_mask] - y_true[neg_mask]) <= 1)) if neg_mask.any() else 0
    pos_w1_acc = float(np.mean(np.abs(y_pred[pos_mask] - y_true[pos_mask]) <= 1)) if pos_mask.any() else 0

    return {
        "total_valid": len(valid),
        "exact_match": exact_match,
        "exact_match_acc": round(exact_match / len(valid), 4),
        "within_one": within_one,
        "within_one_acc": round(within_one / len(valid), 4),
        "mae": round(mae, 4),
        "rmse": round(rmse, 4),
        "mean_bias": round(mean_bias, 4),
        "spearman_r": round(float(spearman_r), 4),
        "spearman_p": round(float(spearman_p), 6),
        "pearson_r": round(float(pearson_r), 4),
        "pearson_p": round(float(pearson_p), 6),
        "cohens_kappa_quadratic": round(float(kappa_qw), 4),
        "cohens_kappa_linear": round(float(kappa_lw), 4),
        "negative_pole_within1_acc": round(neg_w1_acc, 4),
        "positive_pole_within1_acc": round(pos_w1_acc, 4),
        "per_label": per_label,
        "confusion_matrix_labels": MOOD_LABELS,
        "confusion_matrix": cm.tolist(),
    }


def subgroup_metrics(pairs):
    """Compute metrics split by MDD vs MDD->BD groups."""
    results = {}
    for label, name in [(0, "MDD"), (1, "MDD_to_BD")]:
        group = [p for p in pairs if p["shift_label"] == label]
        if not group:
            continue

        # State metrics for subgroup
        valid_state = [p for p in group if p["llm_state"] in STATES]
        y_true_s = [p["expert_state"] for p in valid_state]
        y_pred_s = [p["llm_state"] for p in valid_state]
        state_acc = sum(1 for a, b in zip(y_true_s, y_pred_s) if a == b) / len(y_true_s) if y_true_s else 0

        # Mood metrics for subgroup
        valid_mood = [p for p in group if isinstance(p["llm_mood"], int)]
        if valid_mood:
            yt = np.array([p["expert_mood"] for p in valid_mood])
            yp = np.array([p["llm_mood"] for p in valid_mood])
            exact = int(np.sum(yt == yp))
            w1 = int(np.sum(np.abs(yt - yp) <= 1))
            mae = float(np.mean(np.abs(yp - yt)))
            bias = float(np.mean(yp - yt))
        else:
            exact = w1 = 0
            mae = bias = 0.0

        results[name] = {
            "total": len(group),
            "state_accuracy": round(state_acc, 4),
            "mood_exact_match": exact,
            "mood_exact_acc": round(exact / len(valid_mood), 4) if valid_mood else 0,
            "mood_within_one": w1,
            "mood_within_one_acc": round(w1 / len(valid_mood), 4) if valid_mood else 0,
            "mood_mae": round(mae, 4),
            "mood_mean_bias": round(bias, 4),
        }

    return results


def uncertain_analysis(pairs):
    """Analyze the UNCERTAIN label distribution."""
    uncertain = [p for p in pairs if p["llm_state"] == "UNCERTAIN"]
    if not uncertain:
        return {"count": 0}

    by_expert_state = Counter(p["expert_state"] for p in uncertain)
    by_expert_mood = Counter(p["expert_mood"] for p in uncertain)
    by_group = Counter("MDD_to_BD" if p["shift_label"] == 1 else "MDD" for p in uncertain)

    return {
        "count": len(uncertain),
        "percentage": round(len(uncertain) / len(pairs) * 100, 2),
        "by_expert_state": dict(by_expert_state),
        "by_expert_mood": {str(k): v for k, v in sorted(by_expert_mood.items())},
        "by_group": dict(by_group),
    }


def outlier_analysis(pairs):
    """Analyze mood outliers (|diff| > 1)."""
    valid = [p for p in pairs if isinstance(p["llm_mood"], int)]
    outliers = [p for p in valid if abs(p["llm_mood"] - p["expert_mood"]) > 1]

    # Categorize error patterns
    manic_to_dep = sum(
        1 for p in outliers
        if p["expert_state"] in ("MANIC", "HYPOMANIC") and p["llm_state"] == "DEPRESSIVE"
    )
    dep_to_stable = sum(
        1 for p in outliers
        if p["expert_state"] == "DEPRESSIVE" and p["llm_state"] in ("STABLE", "UNCERTAIN")
    )

    return {
        "total_outliers": len(outliers),
        "outlier_rate": round(len(outliers) / len(valid) * 100, 2) if valid else 0,
        "manic_hypomanic_to_depressive": manic_to_dep,
        "depressive_to_stable_or_uncertain": dep_to_stable,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__,
                                     formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--prompt-version", type=str, default="improved_v6",
                        help="AnalysisRecord.prompt_version filter (default: improved_v6).")
    parser.add_argument("--subset", choices=["tuning", "holdout", "all"], default="holdout",
                        help="ExpertLabel.evaluation_subset filter; 'all' disables the filter "
                             "(default: holdout — the paper's external validation subset).")
    parser.add_argument("--model-version", type=str, default=None,
                        help="AnalysisRecord.model_version filter (default: no filter).")
    parser.add_argument("--output", type=str, default=None,
                        help="Output JSON path (default: ../data/paper_metrics.json relative to this script).")
    args = parser.parse_args()

    subset_filter = None if args.subset == "all" else args.subset

    pairs = extract_pairs(
        prompt_version=args.prompt_version,
        subset=subset_filter,
        model_version=args.model_version,
    )
    if not pairs:
        print(
            f"ERROR: No pairs found for prompt_version='{args.prompt_version}', "
            f"subset='{args.subset}', model_version='{args.model_version}'. "
            "Confirm the labeling run has completed for this combination.",
            file=sys.stderr,
        )
        sys.exit(1)

    results = {
        "filter": {
            "prompt_version": args.prompt_version,
            "subset": args.subset,
            "model_version": args.model_version,
        },
        "dataset_summary": {
            "total_posts_validated": len(pairs),
            "mdd_count": sum(1 for p in pairs if p["shift_label"] == 0),
            "mdd_to_bd_count": sum(1 for p in pairs if p["shift_label"] == 1),
        },
        "state_classification": state_metrics(pairs),
        "mood_label": mood_metrics(pairs),
        "subgroup": subgroup_metrics(pairs),
        "uncertain": uncertain_analysis(pairs),
        "outlier_patterns": outlier_analysis(pairs),
    }

    # Default output: data/paper_metrics.json (one dir up from scripts/)
    output_path = args.output or os.path.join(
        os.path.dirname(os.path.dirname(os.path.abspath(__file__))),
        "data", "paper_metrics.json",
    )
    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(results, f, indent=2, ensure_ascii=False)

    print(f"Metrics saved to {output_path}")
    print(f"  filter: prompt_version='{args.prompt_version}', subset='{args.subset}'")
    print(f"  pairs: {len(pairs)}")


if __name__ == "__main__":
    main()
