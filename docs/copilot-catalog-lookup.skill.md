---
name: ADE Catalog Discovery Skill
description: Dynamically discover the right Azure Deployment Environments catalog template for any project and return minimal, token-efficient guidance
model: gpt-5
---

# ADE Catalog Discovery Skill

## Purpose
Use this skill to discover environment templates at runtime instead of hardcoding template names in prompts.
This skill is project-agnostic and works across customers and repositories.

## Primary Behavior
When the user asks for infrastructure guidance, do this in order:

1. Detect context
- Required: project name.
- Optional: dev center name or endpoint.
- If missing, ask for only the missing value.

2. Discover catalogs dynamically
- Call: az devcenter admin catalog list -g <resourceGroup> -d <devCenter>
- Keep only catalogs where connectionState is Connected and syncState is Succeeded.

3. Discover environment definitions dynamically
- For each healthy catalog, call:
  az devcenter dev environment-definition list --dev-center-name <devCenter> --project-name <project> --catalog-name <catalog>
- Build a candidate list from:
  name, summary, description, templatePath, parameter names, parameter descriptions.

4. Match to user intent
- Score each candidate by keyword overlap with user ask.
- Prefer exact matches in this order:
  name > summary > description > parameters.
- Return top 1 match by default; top 3 if confidence is low.

5. Return concise recommendation
Always return:
- Recommended template name
- Why it matches (one sentence)
- Required/important parameters only
- One deployment command
- One fallback option if confidence is low

## Token-Efficiency Rules
- Never preload static template catalogs in the prompt.
- Never dump full JSON unless user requests raw output.
- Keep response to 8-15 lines by default.
- Only expand when user asks for detail.

## Output Format
Use this exact structure:

Match: <template-name>
Why: <single-sentence reason>
Catalog: <catalog-name>
Key parameters:
- <param>: <short hint>
- <param>: <short hint>
Command:
az devcenter dev environment create --dev-center-name <devCenter> --project-name <project> --catalog-name <catalog> --environment-definition-name <template> --environment-type <envType> --name <envName> --parameters '<json>'
Fallback: <second-best template or next action>

## If No Match Found
- Return: No strong template match found.
- Then provide top 3 closest templates with one-line reasons.
- Ask one clarifying question only.

## Safety + Reliability
- If catalog sync is failed/disconnected, mention it and skip that catalog.
- If no environment definitions are available, guide user to fix catalog sync first.
- Do not claim provisioning succeeded unless a create/show call confirms it.

## Example Minimal Response
Match: webapp-demo
Why: Your request mentions a web API with standard monitoring and optional storage.
Catalog: github-catalog
Key parameters:
- appServicePlanSku: Basic for dev, Standard for production
- webAppRuntime: NODE|18-lts for Node workloads
Command:
az devcenter dev environment create --dev-center-name dc-contoso-platform --project-name ContosoPlatform --catalog-name github-catalog --environment-definition-name webapp-demo --environment-type DevTest --name my-api-dev --parameters '{"environmentName":"my-api-dev","appServicePlanSku":"Basic","webAppRuntime":"NODE|18-lts","enableStorage":false,"envType":"dev"}'
Fallback: If you need data-tier resources, choose the closest template with database parameters.
