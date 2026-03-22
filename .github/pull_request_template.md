<!--
IMPORTANT:
This template is mandatory.
All sections must be thoughtfully completed before requesting review.
Skipping any section requires explicit approval from the Delivery Manager.

Refer to inline comments for guidance on how to complete each section.
-->

### 1. Summary

**Context / Ticket link:** 

**What does this PR change?**

<!--
Describe the changes at feature level (not code level).
Focus on business/scientific impact, not implementation details.
-->

- Functional change:
- Data impact (if any):

---

### 2. Testing

<!--
The developer is responsible for performing vigilant QA testing before requesting review.
This is a quality gate, not a formality.
-->

- [ ] R Package runs locally without errors
- [ ] Feature manually tested end-to-end
- [ ] The business logic aligns with the corresponding ticket acceptance criteria
- [ ] Existing related features were tested and are not impacted
- [ ] No unintended side effects observed during exploratory testing
- [ ] Possible edge cases considered and tested
- [ ] Unit tests added or updated (if applicable)

**Manual test steps**

<!--
Clearly describe how you validated the feature.
Be specific enough for a reviewer to reproduce.
-->

| Scenario | Action / Input | Expected Result | Result |
|----------|---------------|----------------|--------|
|          |               |                |        |
|          |               |                |        |

<!--
Attach screenshots, GIFs, logs or console outputs if relevant.
-->

---

### 3. Risk & Impact (if relevant)

<!--
Indicate whether this PR introduces any functional, architectural, data or performance risk.
If any box is checked, briefly justify below.
-->

Does this PR introduce any risk regarding:

- [ ] Business / Scientific Logic
- [ ] Data integrity
- [ ] Performance
- [ ] Security / Authentication

If yes, briefly explain:

---

### 4. Code Quality Self-Check

<!--
This is a self-review gate.
If any box cannot be confidently checked,
the PR is not ready for review.
-->

- [ ] Naming and coding style strictly follows [Applitics conventions](https://github.com/APPLITICS/applitics-delivery-system/blob/main/coding_standards.md)
- [ ] No unresolved merge conflicts; any resolved conflicts were carefully validated and do not introduce regression
- [ ] No dead code, unused datasets, or debug artifacts remain
- [ ] Errors are explicitly validated and handled with clear messaging
- [ ] No hardcoded secrets, credentials, or environment-specific paths
- [ ] Code structure is modular, readable, and logically organized
- [ ] No unnecessary complexity or over-engineering introduced
- [ ] Code is self-explanatory and appropriately documented
- [ ] No avoidable warnings or errors appear in the terminal (warnings are addressed, not suppressed)

---

### 5. Reviewer Focus

<!--
Indicate where deeper review is needed.
Highlight uncertainty, complexity, or sensitive logic.
Do not leave empty if PR contains non-trivial logic.
-->

**Please focus specifically on:**

🔎 Reviewers: please ensure the Applitics Code Review Checklist is followed before approval.
[Reviewer Checklist](https://github.com/APPLITICS/applitics-delivery-system/blob/main/qa_code_review_governance.md)
