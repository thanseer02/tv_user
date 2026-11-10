# AI-Agent Specification Questionnaire

If any requirements, API details, designs, or variables are missing during feature development, copy this questionnaire, populate the fields you know, and prompt the developer for the missing details.

---

### Hello! To implement the requested feature correctly and align with the project architecture, please provide the missing details below:

#### 1. API Endpoint Details
- **Endpoint Route**: `[e.g., /owner/device/list]`
- **HTTP Method**: `[GET / POST / PUT / DELETE]`
- **Headers Needed**: `[Default (Auth/Lang/Tenant) or Custom]`
- **Request Body JSON Template**:
  ```json
  // Paste request structure here
  ```
- **Response Body JSON Template**:
  ```json
  // Paste response structure here
  ```
- **Is Pagination Needed?**: `[Yes / No]` (If Yes, what are the limit/offset defaults?)

#### 2. UI & Design Specifications
- **Figma Design / Screengrab Path**: `[Please link or paste design context]`
- **Typography & Font Override**: `[Default OpenSans or other]`
- **Color Palettes**: `[Does this require new BrandColors tokens, or can we use existing context.brand options?]`
- **Responsive Guidelines**: `[Standard 428 x 926 grid dimensions]`

#### 3. Secrets & Environment Variables
- **Sensitive Configurations**: `[Please add credentials directly to your local .env file. What key suffix should the agent reference?]`

#### 4. Navigation Flow
- **Source View**: `[From which screen does the user navigate to this page?]`
- **Destination Parameters**: `[What variables are required in the destination Params class?]`
