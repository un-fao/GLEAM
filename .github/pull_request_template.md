> [!IMPORTANT]
>
> This template is mandatory.  
> All sections must be thoughtfully completed before requesting review.  
> Skipping any section requires explicit approval from the Delivery Manager.

### 1. Summary

**Context / Ticket link:**  
_Reference the issue or explain business context briefly_

**What does this PR change?**

_Describe the change at feature level (not code level)_

- Functional change:
- UI change (if any):
- Backend logic change:
- Data impact (if any):

---

### 2. Testing

_The developer is responsible for performing vigilant QA testing before requesting review_

- [ ] App / software runs locally without error
- [ ] Feature manually tested end-to-end
- [ ] The business logic aligns with the corresponding ticket acceptance criteria
- [ ] No visual breaks (layout, spacing, responsiveness, etc.) (if applicable)
- [ ] Existing related features were tested and are not impacted
- [ ] No unintended side effects observed during exploratory testing
- [ ] Possible edge cases considered and tested
- [ ] Unit tests added or updated (if applicable)

**Manual test steps**

_Describe exactly how you validated the feature QA_

| Scenario | Action / Input | Expected Result | Result |
|----------|---------------|----------------|--------|
|          |               |                |        |
|          |               |                |        |

_Evidence (screenshots / gif / logs if relevant)_

---

### 3. Risk & Impact

_The developer must assess potential risks introduced by this PR and explicitly evaluate impact across critical areas. Be conservative and justify any medium/high risk._

| Area | Risk (Low / Medium / High) | Notes (if relevant) |
|------|----------------------------|---------------------|
| UI (if applicable) | | |
| Server Logic | | |
| Data Layer | | |
| Performance | | |
| Authentication / Security | | |

---

### 4. Code Quality Self-Check

_The developer must critically review their own code before requesting review.  
This is a quality gate, not a formality.  
If any box cannot be confidently checked, the PR is not ready._

- [ ] Naming and coding style follows [Applitics conventions](https://github.com/APPLITICS/applitics-delivery-system/blob/main/coding_standards.md)
- [ ] No merge conflicts, and if conflicts occurred, they have been properly resolved and do not introduce regressions
- [ ] No dead code, dead datasets or debug artifacts
- [ ] Errors are validated and handled clearly
- [ ] No hardcoded secrets or paths
- [ ] Structure is modular and readable
- [ ] No unnecessary complexity introduced
- [ ] Code is self-explanatory and properly documented
- [ ] No error or avoidable warning messages are returned in the terminal (warnings must be properly addressed, not suppressed)

---

### 5. Reviewer Focus

_The developer must explicitly indicate where deeper review is needed.  
Highlight areas of uncertainty, complexity, or architectural sensitivity.  
Do not leave this section empty if the PR contains non-trivial logic._

**Please focus specifically on (e.g., logic in X, edge cases around Y, perf in Z):**

> [!IMPORTANT]
> Reviewers must follow the official Applitics Code Review Checklist before approving this PR: [Reviewer Checklist](https://github.com/APPLITICS/applitics-delivery-system/blob/main/qa_code_review_governance.md)
