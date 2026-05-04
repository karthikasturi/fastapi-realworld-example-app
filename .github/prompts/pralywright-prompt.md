# 🧪 Playwright Test Generator – Prompt Template

## Instructions for GitHub Copilot
Before generating any test, ask the user the following questions one by one and wait for their answers. Use the answers to fill in the template below.

---

### 📋 Clarifying Questions (Ask Before Generating)

1. **Page name** – What page are you writing the test for? (e.g., Signup, Login, Checkout)
2. **Endpoint/Route** – What is the full URL or route for this page? (e.g., `http://localhost:4100/register`)
3. **Form fields** – What input fields does this page have? List each field and its placeholder or label text. (e.g., Username → "Your Name", Email → "Email Address")
4. **Primary action** – What is the main button or action the user takes? (e.g., "Sign up", "Login", "Submit Order")
5. **Success behavior** – What happens after the action succeeds? Choose one or describe:
   - Redirect to a specific route (provide the URL or path)
   - A success message appears (provide the text)
   - A specific element becomes visible (describe it)
6. **Auth state** *(optional)* – After the action, is the user logged in? Should we verify a logged-in UI element like a username, avatar, or nav link?
7. **Test file location** – Where should the test file be created? (e.g., `tests/signup.spec.ts`)

---

## ✅ Prompt Template (Filled After Answers)

```
Role:
You are a QA automation engineer writing beginner-friendly Playwright tests.

Goal:
Generate a Playwright test for the **[PAGE_NAME]** page that validates: **[TEST_GOAL]**.

Scope:
- Create a test only for the [PAGE_NAME] page
- Navigate to: [ENDPOINT_OR_ROUTE]
- Fill in the following fields:
  [FIELD_1_LABEL_OR_PLACEHOLDER] → use a test value like "[SAMPLE_VALUE_1]"
  [FIELD_2_LABEL_OR_PLACEHOLDER] → use a test value like "[SAMPLE_VALUE_2]"
  (add more fields as needed)
- Click the "[PRIMARY_ACTION_BUTTON]" button
- Verify successful behavior: [SUCCESS_BEHAVIOR]
- Do not modify any actual implementation or application behavior — write test scripts only

Constraints:
- Use Playwright test syntax (`@playwright/test`)
- Use readable locators: `getByRole`, `getByLabel`, or `getByPlaceholder`
- Avoid CSS selectors and XPath unless absolutely necessary
- Do not use `waitForTimeout`
- Keep the code simple and beginner-friendly
- Write only one clear, focused test case
- Save the test file to: [TEST_FILE_PATH]

Validation / Verification:
- Assert through visible UI behavior only (no internal state checks)
- Verify the "[PRIMARY_ACTION_BUTTON]" action completes successfully
- Verify the user lands on "[EXPECTED_PAGE_OR_URL]" OR sees "[EXPECTED_VISIBLE_ELEMENT_OR_TEXT]"
- [IF_AUTH]: Verify the logged-in state by checking for "[LOGGED_IN_UI_ELEMENT]"
- Use at least one `expect` assertion
```

---

## 📝 Example (Filled for Signup Page)

```
Role:
You are a QA automation engineer writing beginner-friendly Playwright tests.

Goal:
Generate a Playwright test for the Signup page that validates a new user can register successfully.

Scope:
- Create a test only for the Signup page
- Navigate to: http://localhost:4100/register
- Fill in the following fields:
  "Your Name" → use a test value like "Test User"
  "Email" → use a test value like "testuser@example.com"
  "Password" → use a test value like "Test@1234"
- Click the "Sign up" button
- Verify successful behavior: redirect to home page and logged-in user view is visible
- Do not modify any actual implementation — write test scripts only

Constraints:
- Use Playwright test syntax
- Use getByRole, getByLabel, or getByPlaceholder
- No CSS selectors or XPath
- No waitForTimeout
- Beginner-friendly, single test case
- Save to: tests/signup.spec.ts

Validation / Verification:
- Assert through visible UI behavior
- Verify "Sign up" action completes
- Verify the user lands on "/" or sees the home feed
- Verify logged-in state by checking for a username or nav avatar
- Use at least one expect assertion
```

---

## 🔖 Placeholder Reference

| Placeholder | Description | Example |
|---|---|---|
| `[PAGE_NAME]` | Name of the page being tested | `Signup`, `Login`, `Checkout` |
| `[TEST_GOAL]` | One-line description of what the test validates | `a new user can register successfully` |
| `[ENDPOINT_OR_ROUTE]` | Full URL or route of the page | `http://localhost:4100/register` |
| `[FIELD_N_LABEL_OR_PLACEHOLDER]` | Label or placeholder text of each form field | `"Email Address"`, `"Password"` |
| `[SAMPLE_VALUE_N]` | Test data value for each field | `testuser@example.com`, `Test@1234` |
| `[PRIMARY_ACTION_BUTTON]` | Exact text on the submit button | `Sign up`, `Login`, `Place Order` |
| `[SUCCESS_BEHAVIOR]` | What the UI shows on success | `redirect to /home`, `shows "Welcome" banner` |
| `[TEST_FILE_PATH]` | Path where test file should be saved | `tests/signup.spec.ts` |
| `[EXPECTED_PAGE_OR_URL]` | URL or route the user lands on after action | `/`, `/dashboard` |
| `[EXPECTED_VISIBLE_ELEMENT_OR_TEXT]` | Visible text or element confirming success | `"Welcome back!"`, `user avatar` |
| `[IF_AUTH]` | Remove this tag if auth verification is not needed | *(remove if not applicable)* |
| `[LOGGED_IN_UI_ELEMENT]` | UI element confirming logged-in state | `username in navbar`, `profile icon` |

---

## 💡 Usage Tips

- Save this file as `prompts/playwright-test-template.md` in your project root
- Reference it in your GitHub Copilot Chat with: `Use @prompts/playwright-test-template.md to generate a test`
- Reuse across pages by answering the clarifying questions for each new page
- Extend the template with an **Edge Cases** section for negative tests (invalid email, duplicate user, empty fields)
