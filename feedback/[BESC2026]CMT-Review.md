# View Reviews

Paper ID	96

Paper Title	Few-Shot Prompt-Based Longitudinal Mood State Analysis of Bipolar Disorder on Social Media

Track Name	Main Track

## Reviewer #1

### Questions

- 1. Summary

  - The paper utilizes a prompt-based LLM to label social-media posts related  to bipolar disorder (BD). Its contribution includes analysis at two  levels: per-post mood states and 14-day period-level mood trends.

- 2. Strengths

  - The paper identifies a clear research gap and presents a detailed,  well-justified methodology. For example, the authors justify the 14-day  window based on DSM-5 criteria.

    It provides a detailed error analysis that links identified failure patterns to specific schema rules.

    The paper is transparent about its limitations, including the manic-recall  problem and the lack of expert validation for period-level outputs.

- 3. Weaknesses

  - Lack of direct expert validation for the period-level labels.
    Limited cross-model comparison. The paper includes a GPT-5.5 probe, but GPT-5.5 refused to classify 71% of the held-out posts, preventing a complete  comparison.

- 4. Detailed comments

  - Given that the period-level labels were not directly validated by experts,  despite period-level analysis being one of the main contribution of the  paper, a representative sample should be evaluated by qualified expert  annotators. Although this issue is acknowledged in the limitations,  additional validation would strengthen the period-level findings.

    Given the study’s limitations, the period-level analysis should be described as exploratory.

    The following sentence should be supported by a citation: “The trend  distributions are broadly consistent with clinical expectations for  BD-related online discussion.”

    The paper uses Gemini 3.1 Pro,  released on 19 February 2026, but reference [20] cites the general  Gemini family report from 2024 rather than documentation specific to  Gemini 3.1 Pro.

- 5. Reviewer's recommendation.

  - Accept

- 6. Reviewer's confidence.

  - Low

##                     Reviewer #2                                                                                                                   

### Questions

- 1. Summary

  -  The paper proposes a DSM-5-grounded few-shot prompting schema that uses an LLM (Gemini 3.1 Pro) to annotate Reddit posts from bipolar-disorder  communities at two granularities: per-post mood state and 14-day  period-level trend (dominant state, direction, change points).  Post-level classification is externally validated against the  expert-labeled BD-Risk dataset (macro F1 0.519, with 87.9% depressive  recall but only 35.7%/6.7% hypomanic/manic recall), and the method is  then applied to a longitudinal cohort of 105 self-identified BD Reddit  users to produce mood trajectories, observing depressive-pole  predominance broadly consistent with clinical expectations.

- 2. Strengths

  - • A rigorous evaluation design for an LLM-annotation paper:  author-disjoint held-out test set, a zero-shot baseline, a fine-tuned  supervised baseline (ModernBERT), and a cross-model feasibility probe  (GPT-5.5).
    •	Thoughtful schema design directly grounded in DSM-5  episode-duration criteria (the 14-day window choice is well justified  rather than arbitrary).
    •	Adds a needed contribution to the field, which is longitudinal, period-level trajectory annotation.

- 3. Weaknesses

  - •	The manic held-out class is tiny (n≈15), so per-class numbers for that pole carry very wide uncertainty.
    • The upstream LLM-based patient-verification step is itself unvalidated — no accuracy check against ground truth, so misclassified cohort members could inject unknown noise before mood annotation even starts.
    •	The primary longitudinal demonstration (1,794 periods, 15,423 posts) has zero independent validation.
    It is unclear why the authors used OpenAI’s GPT-5.5, not others. Also,  diverse alternatives could be used and evaluated against each other.

- 4. Detailed comments

  - •	Obtain or construct even a small expert-annotated period-level validation set to partially ground the longitudinal claims.
    •	Validate the patient-verification classifier against a manually reviewed subsample.
    •	Report confidence intervals throughout, especially for the small Manic class.

- 5. Reviewer's recommendation.

  - Weak accept

- 6. Reviewer's confidence.

  - Medium

##                     Reviewer #3                                                                                                                   

### Questions

- 1. Summary

  - This paper proposes a few-shot prompt-based framework for longitudinal  mood-state analysis of bipolar disorder (BD) using large language  models. The proposed method introduces a DSM-5-guided prompting schema  to annotate both post-level mood states and 14-day period-level mood  trajectories without task-specific training. Experimental validation on  the BD-Risk dataset demonstrates reasonable performance under  low-resource settings, and the framework is further applied to a Reddit  cohort for longitudinal analysis.

- 2. Strengths

  - 1) Unlike previous work focusing primarily on diagnosis or risk  prediction, this work addresses longitudinal mood-state annotation and  trajectory analysis, which is more clinically relevant for monitoring  bipolar disorder progression. 
    2) The proposed DSM-5-guided prompting strategy requires no fine-tuning or labeled training data, making it  practical for low-resource clinical NLP applications. 
    3) The  annotation schema is carefully designed with DSM-5 rules, safety  constraints, synthetic few-shot demonstrations, and explicit reasoning  outputs, which significantly improve annotation consistency over a  zero-shot baseline.

    

- 3. Weaknesses

  - 1) The proposed method relies heavily on carefully handcrafted prompts and synthetic examples. It remains unclear whether similar performance can  be achieved when applying the framework to other datasets, languages, or clinical domains without redesigning the prompt.
    2) The experimental comparison mainly includes a zero-shot prompt and a supervised  ModernBERT baseline. The paper lacks comparisons with recent  instruction-tuned LLMs or retrieval-augmented prompting approaches,  making it difficult to evaluate the relative competitiveness of the  proposed framework.
    3) How sensitive is the performance to the  selected 14-day window? Would different window sizes (e.g., 7 days or 30 days) affect the longitudinal trends? 
    4) The few-shot prompt  contains eight synthetic examples. How was this number determined? Has  an ablation study been conducted on different numbers of demonstrations?
    5) The prompt uses Gemini 3.1 Pro as the primary model. To what extent are the results reproducible across other LLM providers considering  differences in safety policies?

    

- 4. Detailed comments

  - This paper addresses an important and clinically relevant issue and proposes a practical prompt-based annotation framework that eliminates the need  for fine-tuning. However, the overall organization of the manuscript  requires improvement, and the logical progression in presenting the  methodology and analysis appears somewhat weak. Most critically, the  paper lacks an "Ablation Study" section, which is essential for  validating the empirical choices made within a prompt-engineering  framework. Resolving these structural and logical issues, alongside the  aforementioned weaknesses, will significantly elevate the scientific  rigor and overall impact of this work.

- 5. Reviewer's recommendation.

  - Weak accept

- 6. Reviewer's confidence.

  - High

##                     Reviewer #4                                                                                                                   

### Questions

- 1. Summary

  - This paper proposes a few-shot, prompt-based approach for annotating  bipolar-disorder-related social media content at two temporal  granularities. At the post level, Gemini 3.1 Pro assigns one of five  mood-state labels - Depressive, Stable, Hypomanic, Manic, or Uncertain - using a schema described as grounded in DSM-5 criteria and eight  synthetic examples. At the period level, posts are grouped into 14-day  windows and annotated with a dominant state, trend direction, change  points, mixed-feature specifiers, and a narrative summary.
    Post-level performance is evaluated against categorical labels derived from the  ordinal mood scores in BD-Risk. The held-out evaluation contains 145  posts from authors disjoint from the 314-post development set. On the  138 non-abstained instances, the method reports a macro-F1 of 0.519,  with substantially higher recall for Depressive (87.9%) and Stable  (78.4%) than for Hypomanic (35.7%) and Manic (6.7%). The paper also  compares the full prompt with a minimal zero-shot prompt, fine-tunes  ModernBERT on different amounts of development data, conducts a  cross-model probe with GPT-5.5, and presents a qualitative error  taxonomy.
    The approach is then applied to 15,423 posts and comments  from 105 self-identified Reddit users, producing 1,794 annotated 14-day  periods. The resulting distributions show predominantly Stable and  Depressive periods, with fewer Hypomanic and Manic periods. The paper  discusses the intended research uses and limitations of the resulting  annotations.

- 2. Strengths

  - 1. Relevance to BESC. The problem is relevant to BESC's intersection of  AI, behavioral science, social media analysis, and mental health.  Longitudinal analysis is potentially more informative than static  diagnosis prediction and fits the conference's interest in LLMs for  behavioral and social computing.
    2. Evaluation split and reporting.  The evaluation split is author-disjoint, and the paper provides the  complete confusion matrix rather than reporting only an aggregate score. The distinction between accuracy including and excluding abstentions is also informative.
    3. Breadth of experiments. The experimental  section includes more than a single headline result: a zero-shot  comparison, a supervised ModernBERT baseline, a cross-model feasibility  probe, and an error analysis. The authors are appropriately candid about the very low manic-side recall and the limitations of the period-level  evaluation.

- 3. Weaknesses

  - 1. The central longitudinal contribution is not directly validated. None  of the 1,794 dominant-state, trend-direction, change-point, or  mixed-feature annotations is compared with expert or human ground truth. The reported distributions and four selected timelines demonstrate that the pipeline produces outputs, but not that those outputs measure  actual longitudinal mood dynamics.
    2. The clinical construct validity is insufficiently established. DSM-5 episode concepts require duration, symptom co-occurrence, functional impact, and clinical context that are often unavailable in a single post. Several operational rules instead  rely on surface linguistic features. Moreover, the evaluation labels are deterministic transformations of ordinal BD-Risk scores rather than  direct expert annotations of the proposed categorical states.
    3. Performance is weakest on the defining manic side of bipolar disorder.  Only one of 15 Manic cases is correctly detected, and most Manic cases  are classified as Depressive. Even if some errors originate from  BD-Risk's annotation policy, the present experiment cannot determine how much is label noise versus model failure. This makes the generated  manic-side trajectories difficult to trust.
    4. The 'no labeled data'  and low-annotation-cost claims are misleading. Although the model is not fine-tuned and the eight displayed examples are synthetic, the rules  and examples were iteratively developed using error analysis on 314  labeled BD-Risk posts. The method-development process therefore did  consume task-specific labeled data, as did the ModernBERT baseline  against which annotation cost is compared.

- 4. Detailed comments

  - 1. Direct validation of the longitudinal outputs is necessary. Sections  5-7 treat period-level annotation as the main extension beyond existing  post-level resources, but there is no criterion validity for dominant  state, direction, or change point. A minimally adequate evaluation would include a stratified sample of periods spanning all predicted states,  trend directions, confidence levels, user activity levels, and content  types. Multiple qualified annotators should label these periods  independently, with agreement and model-versus-consensus metrics  reported. Change points require a temporal-tolerance metric rather than  only exact matching. Until such an evaluation is available, claims about episode onset, escalation, early warning, or rapid cycling should be  removed or explicitly framed as unvalidated hypotheses.
    2. The period construction and aggregation require clarification and sensitivity  tests. Section 3 states that all windows between the first and last post are retained and empty windows receive NO_DATA, but Table 6 sums to  1,794 periods without reporting a NO_DATA category. Please report total  windows, non-empty windows, and posts per window. It is also unclear  whether the period prompt receives raw posts, post-level predictions, or both, and how 'dominant' is operationalized. From Table 7, only  approximately 16.1% of individual items receive a polar label, whereas  43.2% of periods receive a polar dominant state. This large  transformation needs a post-to-period contingency analysis. Robustness  should also be tested under alternative window lengths and shifted  window anchors because a first-post anchor can arbitrarily split an  episode.
    3. The paper overstates the status of the BD-Risk labels.  The original BD-Risk paper describes labels assigned by trained  researchers under psychiatric guidance, followed by expert validation on a random 150-post subset; it does not appear that every one of the  7,346 labels was directly assigned by a psychiatrist or clinical  psychologist. Please establish whether the 145 evaluation posts overlap  the expert-validated subset and revise 'expert-assigned gold labels'  accordingly. More importantly, the proposed four states were not  directly annotated: they are derived from an ordinal scale via a new  mapping. A stronger test would obtain direct, text-only categorical  annotations under the proposed schema. Reporting performance on the  original seven-point ordinal task would also help separate model error  from mapping error.

- 5. Reviewer's recommendation.

  - Weak reject

- 6. Reviewer's confidence.

  - High