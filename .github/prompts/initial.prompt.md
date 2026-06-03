
I need you to generate a complete customer-demo-ready solution in this repo for an enterprise discussion with Kelley Services.

GOAL
Create:
1) a polished single-page HTML one-pager for customer discussion, and
2) a runnable end-to-end Azure Deployment Environments (ADE) catalog demo environment that showcases a platform engineering / service catalog pattern using a repository-backed catalog from GitHub or Azure Repos.

CONTEXT
This is for an enterprise customer conversation about:
- platform engineering
- infrastructure as code standardization
- service catalog patterns
- self-service infrastructure
- Azure DevOps + GitHub coexistence
- reducing the need for app engineers to understand Terraform deeply
- using Azure Deployment Environments catalogs backed by GitHub or Azure Repos

The solution should show how a platform team can publish approved infrastructure templates into a catalog repository, and how application teams can self-service an approved environment safely with governance.

IMPORTANT GUIDELINES
- Do NOT ask clarifying questions.
- Make reasonable assumptions and generate everything needed.
- Prefer practical, low-cost, demo-friendly Azure resources.
- Keep the infrastructure simple and easy to explain to a customer.
- Use placeholders for tenant/subscription/resource names where needed.
- Output production-quality files, not pseudocode.
- Show the final file tree first, then provide the full contents of every file.
- Make the demo lean, clean, and executive-presentable.

WHAT TO BUILD

PART A — CUSTOMER ONE-PAGER HTML
Create a self-contained single HTML file at:
docs/customer-one-pager.html

Requirements:
- Modern responsive HTML
- Tailwind CSS via CDN
- Clean Microsoft/Azure-style design
- Executive-friendly layout
- Light professional color palette with subtle gradients
- Architecture-style cards and sections
- Minimal inline SVG visual diagrams
- No external build system required
- Must open locally in a browser

Content sections:
1. Hero
   - Title: “Platform Engineering and Self-Service Environment Catalog on Azure”
   - Subtitle explaining Azure Deployment Environments + GitHub/Azure Repos catalog pattern
   - Short tagline focused on speed, governance, and standardization

2. Customer Challenge
   - Inconsistent infrastructure provisioning
   - Too much Terraform/platform complexity for app teams
   - Slow onboarding
   - Governance / RBAC / standards are hard to scale
   - Inconsistent CI/CD and template reuse

3. Target Operating Model
   - Platform team publishes curated templates
   - Catalog is backed by GitHub or Azure Repos
   - ADE syncs the catalog
   - App teams self-service approved environments
   - Governance and approvals remain centralized

4. End-to-End Flow Diagram
   Show a simple architecture flow:
   Platform Engineers → Repo Catalog → Azure Deployment Environments → Developer Self-Service → Azure Environment Deployment

5. Recommended Reference Architecture
   Include the roles of:
   - Azure Deployment Environments
   - GitHub or Azure Repos
   - environment definitions
   - infrastructure templates
   - managed identity / secure auth
   - governance / RBAC
   - CI/CD integration
   - GitHub Copilot support for platform engineering

6. Why This Helps
   - Faster onboarding
   - Standardized deployments
   - Reduced drift
   - Better governance
   - Better developer experience
   - Reduced infra expertise burden on app teams

7. Suggested Pilot
   - Start with one curated environment type
   - Publish to catalog repo
   - Sync into ADE
   - Let one app team self-service it
   - Validate governance, approvals, and DX
   - Expand to more environment patterns

8. GitHub Copilot + Developer Productivity
   Include examples:
   - generate README and infra docs
   - explain templates
   - scaffold IaC
   - generate pipeline snippets
   - improve developer onboarding

9. Call to Action
   - “Pilot a curated self-service environment catalog”
   - “Start with one pattern and expand”

The one-pager should feel like something I can show directly to a customer in a meeting.

PART B — END-TO-END REPO DEMO
Create a demo implementation in this repo that shows the ADE catalog concept end to end.

Use this repo structure (or improve it if needed, but keep it simple and explain it):

/
  README.md
  docs/
    customer-one-pager.html
    demo-walkthrough.md
    architecture-diagram.svg
  catalog/
    webapp-demo/
      environment.yaml
      main.bicep
      parameters.json
      README.md
  scripts/
    setup-demo.ps1
    setup-demo.sh
    validate-demo.ps1
    validate-demo.sh
  samples/
    app/
      index.html

DEMO DESIGN
Build one simple curated environment definition called:
webapp-demo

This environment should be understandable in a customer meeting and low-cost to demo.
Prefer Bicep for simplicity unless there is a very strong reason to add Terraform.
The environment should deploy a very simple Azure-hosted application footprint such as:
- resource group-scoped deployment
- App Service Plan
- Web App
- optional Storage Account only if truly useful for the story

The environment definition should be suitable for use as an ADE catalog item.

Generate:
1. environment definition file
2. main Bicep template
3. parameters file
4. README explaining the environment
5. sample HTML app content

PART C — SETUP EXPERIENCE
Create setup assets that help me demonstrate the solution end to end.

Generate:
1. A main README.md for the repo
2. A demo-walkthrough.md designed for me to present to a customer
3. PowerShell and Bash setup scripts with placeholders and comments
4. Validation scripts that check whether expected files/configs/resources are present
5. A short “talk track” section in the walkthrough I can use verbally with the customer

The README and walkthrough should explain:
- what the repo contains
- what the ADE catalog pattern is
- how the catalog repo is structured
- how the demo is intended to work
- what I need to configure manually
- what I can show live in a meeting

PART D — SCRIPTING EXPECTATIONS
Generate practical scripts that help me set variables and prepare the demo, but do not hardcode secrets.
Use placeholders like:
<AZURE_SUBSCRIPTION_ID>
<RESOURCE_GROUP_NAME>
<LOCATION>
<DEV_CENTER_NAME>
<PROJECT_NAME>
<CATALOG_NAME>
<GITHUB_OR_AZURE_REPOS_REPO_URL>

If some steps are better handled manually in the Azure portal, state that clearly in the README and walkthrough.
Scripts should be safe, readable, and clearly commented.

PART E — DEMO WALKTHROUGH CONTENT
In docs/demo-walkthrough.md include:
1. Demo objective
2. Architecture overview
3. What to show first
4. What to click/show in the repo
5. What to show in Azure
6. How to explain the catalog pattern
7. How to explain the platform team vs application team model
8. How to explain GitHub / Azure Repos coexistence
9. Suggested customer discussion questions
10. Suggested next steps / pilot framing

Also include a short “2-minute executive summary” and a “5-minute technical walkthrough.”

PART F — QUALITY BAR
- Everything must be coherent and work together as one story
- Use consistent naming
- Use clean markdown
- Use clean indentation and formatting
- Avoid unnecessary complexity
- Keep customer credibility high
- Make the demo feel realistic for an enterprise customer exploring internal platform engineering patterns

OUTPUT FORMAT
1. Show the proposed file tree
2. Then provide the full contents of every file
3. Then provide a short section called “How to use this demo”
4. Then provide a short section called “What I should say in the customer meeting”

Do not give me high-level suggestions only.
Actually generate the files and their full contents.
Also you you already create the resourses on my half in 
tenant: 16b3c013-d300-468d-ac64-7eda0820b6d3 
subscribtion: b6f10878-9f8a-4b3f-8bc5-3464cdd79c77
ADO-org: https://dev.azure.com/gappiahdemo-msft/ (feel free to create a project, repo as needed)
GitHub Account: https://github.com/TeplrGuy