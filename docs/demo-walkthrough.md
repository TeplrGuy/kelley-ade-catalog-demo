---
title: Azure Deployment Environments Catalog Demo Walkthrough
description: Detailed presentation script and customer talking points for the ADE catalog pattern demo
---

# Azure Deployment Environments Catalog Demo Walkthrough

A complete guide to presenting the platform engineering and self-service environment catalog pattern to enterprise customers.

---

## Table of Contents

1. [2-Minute Executive Summary](#2-minute-executive-summary)
2. [5-Minute Technical Walkthrough](#5-minute-technical-walkthrough)
3. [Full Customer Presentation Flow](#full-customer-presentation-flow)
4. [Portal Configuration Checklist](#portal-configuration-checklist)
5. [Live Demo Steps](#live-demo-steps)
6. [Customer Discussion Questions](#customer-discussion-questions)
7. [Handling Objections](#handling-objections)
8. [Copilot Integration Talking Points](#copilot-integration-talking-points)
9. [Suggested Pilot Framing](#suggested-pilot-framing)
10. [Next Steps & Close](#next-steps--close)

---

## 2-Minute Executive Summary

**Use this when time is tight or you're opening a meeting:**

> Today, I want to show you how you can dramatically accelerate your app teams' ability to get new infrastructure environments while keeping governance and standards completely centralized.
>
> We're talking about **platform engineering** using **Azure Deployment Environments**. Here's the idea:
>
> Your **platform team** curates infrastructure patterns—things like "web app with storage," "API backend with database," etc.—and publishes them to a catalog. That catalog sits in GitHub or Azure Repos—somewhere your engineers already work.
>
> **Azure automatically syncs** that catalog and gives your app teams a **self-service button**. They click one button, fill out a few parameters, and in minutes they have a production-ready, fully governed environment.
>
> The magic is: **governance stays centralized**. Every environment they create automatically inherits your RBAC policies, compliance controls, tagging standards, and audit logging. No exceptions. No drift.
>
> The result? App teams go from waiting days for an environment to getting one in minutes. Your platform team goes from a bottleneck to an enabler. And compliance is automatic, not manual.
>
> That's what I want to show you today.

---

## 5-Minute Technical Walkthrough

**Use this in a technical audience or when diving slightly deeper:**

> So here's how it actually works, technically.
>
> **Step 1: Catalog Repository.** Your platform team maintains a Git repository—could be GitHub or Azure Repos—with infrastructure definitions. These are YAML files that describe an environment. One file says, "This is a web app environment. It includes an App Service Plan, a Web App, and optional storage."
>
> **Step 2: Infrastructure Templates.** Each environment definition points to an **Azure Bicep template**—that's infrastructure-as-code. But here's the key: app teams don't write this. Your platform team does it once, and then it's reused a hundred times. The template has all your governance baked in: managed identities, RBAC assignments, compliance tagging, audit logging.
>
> **Step 3: Azure Dev Center.** This is the orchestrator. You point Azure Dev Center at your catalog repository—give it a GitHub PAT or Azure Repos connection—and it automatically syncs. When you update a template, Dev Center picks up the change.
>
> **Step 4: Self-Service Portal.** Developers go to the Azure Developer Portal, click "Create Environment," and they see a list of approved patterns. They pick one, answer a few questions—like "what should I name this?"—and hit deploy.
>
> **Step 5: Deployment.** Behind the scenes, Dev Center executes the Bicep template with the parameters they provided. It creates the resource group, the app service plan, the web app, the managed identity, assigns all the RBAC roles, and hands back a fully functional environment. This happens in minutes.
>
> **All of this is governed.** Every environment created gets the same RBAC, the same tags, the same monitoring, the same compliance checks. It's not a free-for-all. It's controlled consistency at scale.

---

## Full Customer Presentation Flow

### Opening (2 minutes)

**Objective:** Set context and build credibility

**Script:**

> Thank you for making time today. I know platform engineering and infrastructure standardization are top-of-mind for you right now. I want to show you a pattern we're seeing work really well with enterprise customers—companies like yours—to solve a specific problem: how do you let app teams provision infrastructure fast while keeping governance and standards completely locked down?
>
> Most teams face this tradeoff. Either:
>
> - **Option A:** Every app team writes their own Terraform. You get fast provisioning but inconsistent infrastructure, governance nightmares, and your platform team is constantly firefighting.
> - **Option B:** Centralized platform team reviews everything. You get governance but your app teams are blocked waiting for infrastructure. It becomes a bottleneck.
>
> What I'm going to show you today is **Option C: Curated catalogs**. You get speed AND governance. Let me walk through how.

### The Challenge (2 minutes)

**Objective:** Get customers nodding—make them feel like you understand their pain

**Script:**

> Let me start with where most enterprises are today. I'm guessing some of this sounds familiar.
>
> **Inconsistent Infrastructure.** Each app team provisions environments a little differently. One team uses premium App Service plans, another uses basic. One team tags resources "department: engineering," another uses "team: backend." A year in, you've got a hundred snowflake environments and nobody can audit them cleanly.
>
> **Terraform Fatigue.** Your app engineers are great at writing features. They're not infrastructure engineers. But suddenly they need to write Terraform. So either they struggle and slow down delivery, or your platform team ends up writing all the Terraform, and now your platform team is a bottleneck.
>
> **Slow Onboarding.** A new app team wants to launch a new service. They need an environment. Instead of minutes, they're submitting tickets, waiting for the platform team, going back and forth on RBAC assignments and naming conventions. It takes weeks.
>
> **Governance at Scale.** You want RBAC, compliance tags, audit logging, and approved resource types. But enforcing that across dozens of teams, each creating their own infrastructure, is a mess. You end up with policy-enforcement overhead and exceptions everywhere.
>
> The question is: **How do you let teams move fast without losing control?**

### The Solution (3 minutes)

**Objective:** Introduce ADE catalog pattern as the answer

**Script:**

> Here's the pattern: **Platform Engineering with Curated Catalogs on Azure Deployment Environments.**
>
> The idea is simple. Your platform team—that's you—becomes a **product team**. Your product is infrastructure. You curate a set of approved infrastructure patterns. Maybe that's "web app," "API backend," "scheduled job," "data pipeline." You own those templates.
>
> You publish each pattern to a **catalog repository**. That could be in GitHub or Azure Repos. It's just a Git repo with infrastructure definitions and templates.
>
> **Azure Deployment Environments** automatically syncs that catalog. When developers go to the Developer Portal, they see your curated patterns. They pick one, fill in some parameters, and hit deploy. In minutes, they have a fully provisioned, fully governed environment.
>
> The key insight: **Governance is built into the template.** Every environment created from your template automatically gets the same RBAC, the same managed identity, the same tagging, the same monitoring. There's no way to do it wrong. Standardization is not a policy you enforce; it's baked into the infrastructure.
>
> So you've solved all three problems:
>
> - **Consistent Infrastructure:** Same template, same output, every time.
> - **No Terraform Burden:** App teams don't write Terraform. Your platform team owns the template.
> - **Fast Onboarding:** Developers self-service in minutes. No ticket. No wait.
> - **Governance is Automatic:** Compliance and standards are baked in, not bolted on.

### The Architecture (3-4 minutes)

**Objective:** Build credibility by explaining the actual Azure components

**Script:**

> Let me walk through the architecture so you understand what's actually happening.
>
> **The Catalog Repository.** This lives in GitHub or Azure Repos. It contains:
> - **Environment Definitions.** YAML files describing each infrastructure pattern.
> - **Bicep Templates.** The actual infrastructure-as-code.
> - **Parameters.** Input values developers can customize.
> - **Documentation.** Explains the pattern, its use cases, and limitations.
>
> Example environment definition:
>
> ```yaml
> name: Web App Environment
> description: "Standard web app with storage for dev, staging, and production"
> environments:
>   - devops-ready-web-app
> deployed-resources:
>   - name: AppServicePlan
>     type: Microsoft.Web/serverfarms
>   - name: WebApp
>     type: Microsoft.Web/sites
>   - name: StorageAccount
>     type: Microsoft.Storage/storageAccounts
> ```
>
> **Azure Dev Center.** This is the orchestration layer. You tell Dev Center: "Watch this GitHub repo for catalog changes." Dev Center syncs automatically. When you update a template, Dev Center picks it up in real time.
>
> **Managed Identity & RBAC.** Here's where governance happens. Your Bicep template creates a managed identity for the web app and assigns it specific roles—maybe "Reader" on storage, "Contributor" on the resource group. This is embedded in the template. Every environment gets the same setup.
>
> **The Developer Portal.** App engineers see a clean list of approved environment types. They click "Create," fill in parameters, and hit go. Behind the scenes, Dev Center runs the Bicep template, creates resources, assigns identities and roles, and hands back the environment. Takes 2–5 minutes.
>
> **Audit & Compliance.** Every deployment is tracked. You see who created what, when, what parameters they used. RBAC is locked down. Developers can't overprovision expensive SKUs because the template doesn't support it. They can't use unapproved resources because they're not in the template.

### Why This Works (2 minutes)

**Objective:** Connect architecture to business outcomes

**Script:**

> So why is this approach winning with enterprise customers?
>
> **First, Scalability.** You can design one "web app" template and have 50 app teams use it. When you discover a better configuration, you update the template once. All future deployments inherit the improvement. That's the power of treating infrastructure as a product.
>
> **Second, Governance Without Friction.** In traditional models, governance means restrictions and approvals and slowness. Here, governance is invisible. Developers don't feel constrained; they just self-service. But compliance is automatic. That's the magic.
>
> **Third, Platform Team Enablement.** Your platform team moves from a bottleneck to an enabler. Instead of handling deployment tickets, they're designing and evolving infrastructure products. That's much more satisfying work.
>
> **Fourth, GitHub & Azure DevOps Coexistence.** A lot of our customers use both GitHub and Azure DevOps. Some teams prefer GitHub, others Azure DevOps. This pattern works with both. Your catalog repo can be GitHub, and your infrastructure lives in Azure. Or both in Azure DevOps. Flexible.
>
> **Fifth, Copilot Integration.** GitHub Copilot can help your platform team write better Bicep templates, generate documentation, and scaffold new patterns. That's a productivity multiplier for your platform engineering team.

### The Demo (Live or Screenshots) (5-10 minutes)

**Objective:** Make it real and tangible

See [Live Demo Steps](#live-demo-steps) section below for detailed steps.

**Summary Script:**

> Let me show you what this looks like in action. I'm going to:
>
> 1. Show you the catalog repository structure.
> 2. Walk through a Bicep template and explain the governance built in.
> 3. Show you Azure Dev Center and the catalog sync.
> 4. Trigger a new environment deployment and watch it complete.
> 5. Show you the deployed web app and the RBAC configuration.

### Pilot Recommendations (2 minutes)

**Objective:** Make next steps concrete and achievable

**Script:**

> Based on what I've shown you, here's how I'd recommend moving forward.
>
> **Week 1: Design Phase.** We pick one infrastructure pattern that's high-demand for your teams. Maybe it's the web app pattern, or an API backend, or a job runner. Keep it focused and simple.
>
> **Week 2: Catalog Publication.** We write the environment definition and Bicep template. We test it locally. We publish it to a GitHub or Azure Repos catalog repo.
>
> **Week 3: Dev Center Setup.** We stand up Azure Dev Center if you don't have it. We connect it to the catalog repo. We verify the environment shows up in the Developer Portal.
>
> **Week 4: Pilot Deployment.** We have one trusted app team self-service an environment. We watch it work end to end. We collect feedback on the developer experience.
>
> **Week 5–6: Iterate & Validate.** Based on feedback, we refine the template. We validate governance—RBAC, tagging, compliance. We document the pattern and create runbooks for your platform team.
>
> **Post-Pilot: Scale.** Once the pilot environment is validated, you expand to more app teams. You add additional environment patterns based on demand.
>
> Timeline: 4–6 weeks from concept to production validation. Most of that is your team's part-time effort.

### Discussion & Objections (5-10 minutes)

**Objective:** Address concerns and deepen relationship

See [Customer Discussion Questions](#customer-discussion-questions) and [Handling Objections](#handling-objections) sections below.

### Close & Next Steps (2 minutes)

**Objective:** Clear next step and sense of momentum

**Script:**

> I know this is a lot to absorb. But I think you can see how this solves a real problem you're facing. The infrastructure catalog pattern is proven. It's working with other large enterprises. And it's completely aligned with Azure's vision for platform engineering.
>
> Here's what I'd like to do next:
>
> 1. **Schedule a Technical Working Session.** We'll gather your platform engineering team and walk through the architecture in more detail. Answer technical questions. Scope out your first pattern.
>
> 2. **Build a Proof of Concept.** We'll stand up a small ADE dev center and catalog in your subscription. We'll publish one environment definition. We'll have your team self-service it. Make it real.
>
> 3. **Plan the Pilot.** Once the POC works, we'll plan the enterprise pilot. Which pattern do we launch first? Which app teams do we onboard? What's the timeline?
>
> Sound good?

---

## Portal Configuration Checklist

**When to use:** After setup scripts run, before live demo

### Prerequisites

- [ ] Azure subscription access (tenant: `16b3c013-d300-468d-ac64-7eda0820b6d3`, subscription: `b6f10878-9f8a-4b3f-8bc5-3464cdd79c77`)
- [ ] GitHub or Azure Repos access for catalog repo
- [ ] Azure CLI installed and authenticated

### Manual Portal Steps

#### 1. Create Resource Group

```bash
az group create \
  --name rg-ade-demo-eastus \
  --location eastus \
  --subscription b6f10878-9f8a-4b3f-8bc5-3464cdd79c77
```

#### 2. Create Dev Center

In Azure Portal:

1. Navigate to **Azure Deployment Environments**
2. Click **Create Dev Center**
3. **Name:** `dc-platform-demo`
4. **Resource Group:** `rg-ade-demo-eastus`
5. **Location:** `East US`
6. **Managed Identity:** Create new
7. Review and create

#### 3. Add Catalog to Dev Center

In Dev Center settings:

1. Click **Catalogs**
2. Click **+ Add**
3. **Name:** `platform-catalog`
4. **Repository Type:** GitHub (or Azure Repos)
5. **Repository:** `https://github.com/TeplrGuy/ade-catalog-demo`
6. **Branch:** `main`
7. **Folder path:** `catalog`
8. **GitHub PAT (if GitHub):** [Your personal access token with `repo` scope]
9. Review and create

#### 4. Create Project in Dev Center

1. In Dev Center, click **+ Create Project**
2. **Name:** `ProjectAlpha`
3. **Description:** `Platform engineering demo project`
4. **Dev Center:** Select the dev center you created
5. Create

#### 5. Assign RBAC to Dev Center Managed Identity

The Dev Center's managed identity needs permissions to create resources:

```bash
az role assignment create \
  --assignee-object-id <DEV_CENTER_MANAGED_IDENTITY_ID> \
  --role "Contributor" \
  --scope /subscriptions/b6f10878-9f8a-4b3f-8bc5-3464cdd79c77/resourceGroups/rg-ade-demo-eastus
```

To get the managed identity ID:

```bash
az devcenter admin devcenter show \
  --resource-group rg-ade-demo-eastus \
  --dev-center-name dc-platform-demo \
  --query "identity.principalId" -o tsv
```

#### 6. Verify Catalog Sync

1. In Dev Center, go to **Catalogs**
2. Select `platform-catalog`
3. Check **Last synced** timestamp
4. If sync failed, check the error message (usually PAT or folder path issue)

**Troubleshooting Catalog Sync:**

- **"Invalid repository URL"** → Verify the GitHub/Azure Repos URL is correct and accessible
- **"Invalid personal access token"** → GitHub PAT must have `repo` scope; Azure DevOps PAT must have `Code (Read)`
- **"Folder not found"** → Verify the `catalog/` path exists in the repo and contains `environment.yaml` files
- **"No environments found"** → Check that `environment.yaml` files are properly formatted YAML

---

## Live Demo Steps

**Time: 10–15 minutes**

**Prerequisite:** All portal configuration steps completed and catalog synced

### Part 1: Repository Walkthrough (2–3 minutes)

**What you'll show:** The catalog structure

```
catalog/
└── webapp-demo/
    ├── environment.yaml       <-- This defines the environment
    ├── main.bicep             <-- This is the infrastructure
    ├── parameters.json        <-- These are input parameters
    └── README.md              <-- This documents the pattern
```

**Script:**

> Here's the catalog repository. It's just a Git repo. Your platform team owns it. Inside, we have `catalog/` which contains environment definitions.
>
> Each folder—like `webapp-demo`—is one environment pattern. Inside each pattern, you have:
>
> - **environment.yaml:** Describes the pattern to Azure Dev Center. Says "this environment is called 'Web App Demo,' it creates App Service Plan and Web App."
> - **main.bicep:** The actual infrastructure template. Written by your platform team once, reused many times.
> - **parameters.json:** Input parameters developers can customize (like app name, SKU).
> - **README.md:** Documentation for developers on how to use the environment.
>
> That's it. Simple, clean, version controlled.

**Show the files:** Open them in your editor and read key sections.

### Part 2: Bicep Template Review (2–3 minutes)

**What you'll show:** How governance is baked in

**Script:**

> Let me show you the Bicep template. This is where governance lives.
>
> [Open `main.bicep`]
>
> Notice: We're creating an App Service Plan and Web App. But also:
>
> - **Managed Identity:** Every app gets its own identity for secure auth.
> - **Role Assignments:** We're assigning the app specific roles on resources it needs.
> - **Tags:** We're tagging everything with department, environment, cost center. This is automatic—developers don't think about it.
> - **Monitoring:** We're enabling diagnostics logs, sending them to a Log Analytics workspace.
>
> This template was written by your platform team. It represents your infrastructure standards. Every environment deployed from this template automatically gets all this governance. There's no way to do it wrong.
>
> If your compliance team says "we need a new tag for data classification," you update the template once. All future deployments inherit it. That's the power of this pattern.

### Part 3: Dev Center & Catalog Sync (1–2 minutes)

**What you'll show:** The portal side—where the magic happens

**Script:**

> Now let me show you the Azure side. I'm in the Azure Dev Center.
>
> [Navigate to Dev Center → Catalogs]
>
> Here's the catalog sync status. It's watching the GitHub repo. When we pushed our environment definition, Dev Center picked it up automatically.
>
> [Show the synced environment list]
>
> This list shows all available environments from the catalog. For the customer demo, we have `webapp-demo`. If we added more patterns to the repo, they'd automatically appear here.

### Part 4: Trigger a Deployment (5–7 minutes)

**What you'll show:** A real developer self-servicing an environment

**Script:**

> Now let's actually create an environment. This is what your app teams will do.
>
> [Go to Developer Portal → Create Environment, or navigate to the project]
>
> I click "Create Environment." I see the list of available patterns.
>
> [Select webapp-demo]
>
> The portal shows me input parameters:
> - Environment Name
> - App Service Plan SKU
> - Web App runtime
> - (Any other custom parameters)
>
> I fill in the values:
> - Environment Name: "webapp-demo-prod"
> - SKU: "Basic" (remember, the template enforces this is low-cost)
> - Runtime: "Node.js 18"
>
> [Enter parameters]
>
> Now I hit "Create." Azure Dev Center takes the parameters, runs the Bicep template, and deploys everything.
>
> [Hit Create and wait for deployment]
>
> While that's running, let me explain what's happening behind the scenes:
>
> 1. Dev Center executed the main.bicep template with our parameters.
> 2. It created a resource group specifically for this environment.
> 3. It created the App Service Plan, Web App, and Storage Account.
> 4. It created a managed identity for the web app.
> 5. It assigned the identity specific roles.
> 6. It applied all the compliance tags.
> 7. It sent diagnostic logs to a Log Analytics workspace.
> 8. All of this happened automatically, based on the template.
>
> The developer didn't have to write any Terraform. They didn't have to understand RBAC. They just filled out a form.
>
> [Deployment completes]
>
> There we go. Deployment succeeded. The environment is ready.
>
> [Show deployed resources]
>
> Here are the resources that were created. App Service Plan, Web App, Storage Account, managed identity. All created automatically from our template.
>
> [Show the web app URL and open it in browser]
>
> And the web app is already live and serving content.

### Part 5: Governance Review (1–2 minutes)

**What you'll show:** RBAC and compliance in action

**Script:**

> Let me show you the governance side. This is what your compliance team cares about.
>
> [Show resource group IAM → Role Assignments]
>
> Here's the RBAC. The managed identity we created for the web app has specific roles:
> - "Reader" on the resource group
> - "Storage Blob Data Contributor" on the storage account
>
> These were all assigned automatically by the Bicep template. The developer never touched RBAC. Least-privilege access is baked in.
>
> [Show resource tags]
>
> Here are the tags. Every resource got:
> - `department: platform-engineering`
> - `environment: demo`
> - `cost-center: engineering`
> - `created-by: dev-center`
> - `compliance: standard`
>
> Again, automatic. When you need a new tag for regulatory compliance, you update the template. All new deployments inherit it.
>
> [Show monitoring setup]
>
> And diagnostics are enabled. Logs are flowing to a Log Analytics workspace. Your security team can query and alert on app behavior.
>
> Everything governance-related is handled by the template. No manual setup. No exceptions.

---

## Customer Discussion Questions

**Use these to deepen the conversation and understand customer needs**

### Understanding Their Current State

1. "How many infrastructure patterns does your platform team currently maintain?"
2. "When an app team needs a new environment today, how long does it take? Where's the bottleneck?"
3. "How do you ensure all environments follow your naming conventions, tagging standards, and RBAC policies?"
4. "What's your current process for onboarding a new app team or service?"

### Governance & Compliance

5. "What governance and compliance controls are non-negotiable for you?"
6. "How much manual effort does your team spend enforcing those controls?"
7. "Have you had incidents where infrastructure didn't follow your standards? What happened?"
8. "How do you audit infrastructure provisioning today?"

### Developer Experience

9. "Do your app engineers write Terraform/IaC themselves, or does your platform team own all infrastructure?"
10. "If they write IaC, how much of their time does that consume?"
11. "What's the most frequent complaint you hear from app teams about the current infrastructure provisioning process?"

### Organizational

12. "How many app teams would benefit from a self-service catalog?"
13. "What's your biggest concern about moving to a self-service model?"
14. "How does your organization handle the platform team's roadmap today? What's their capacity?"

### Azure & Tools

15. "Are you currently using Azure Dev Center, or would this be new for your team?"
16. "Do your teams prefer GitHub or Azure DevOps?"
17. "Is GitHub Copilot already in your developer workflow, or would this be an opportunity to introduce it?"

### Pilot Planning

18. "If we were to run a 4–6 week pilot, which infrastructure pattern would you want to start with?"
19. "Which app team would be the best first customer for a pilot?"
20. "What would success look like for your organization? How would you measure it?"

---

## Handling Objections

### "We already have infrastructure as code. Why change?"

**Response:**

> Fair point. Many teams already have Terraform or Bicep. The question isn't "do you have IaC?" It's "who writes it?" and "how do you reuse it?"
>
> With traditional IaC, each app team often manages their own Terraform. So you get:
> - Inconsistent patterns (one team uses premium SKUs, another basic)
> - Duplicated effort (nobody shares templates effectively)
> - Governance burden (you have to enforce standards across N different codebases)
>
> The ADE catalog pattern is a reuse mechanism. Your platform team writes the template once. 50 app teams use it without writing any IaC themselves. Consistency and scale you don't get with traditional IaC.
>
> Think of it this way: with traditional IaC, you're giving every app team a toolbox. With the catalog pattern, you're giving them a product. One is flexibility. The other is standardization at scale.

### "Doesn't ADE lock us into Azure?"

**Response:**

> Yes, this pattern is specific to Azure. The infrastructure—the Bicep templates, the Dev Center, the managed identities—that's all Azure.
>
> But your **source control** is not locked in. The catalog repo lives in GitHub or Azure Repos. If you move off Azure someday, you'd need to rewrite the Bicep templates for your new cloud. But the pattern—templates + catalogs + self-service—that's portable.
>
> Most enterprises I talk to are committed to Azure for 3–5 years minimum. This pattern gives you consistent, governed infrastructure for that entire period. It's not reckless to adopt it.

### "This adds another tool to our toolchain. We already have too many tools."

**Response:**

> I hear that. But let me reframe it: this isn't adding a tool; it's **replacing** several processes you're doing manually.
>
> Today, you probably have:
> - Manual steps for provisioning (tickets, reviews, approvals)
> - Manual tagging and RBAC setup
> - Manual documentation and runbooks
> - Manual audits for compliance
>
> This pattern automates all of that into one place. Yes, there's Dev Center to learn. But you're replacing manual tasks, not adding them.
>
> And it's Azure-native. If you're already using Azure DevOps, Azure Repos, or Azure Policy, this integrates seamlessly. You're not learning a standalone tool; you're using parts of Azure you already own.

### "This only works for simple, standardized environments. Our use cases are too diverse."

**Response:**

> That's a really valid point. This pattern is best for standardized patterns. But here's what I'd push back on: how many truly unique environments do you have?
>
> When I interview enterprises, they usually think they have 20 unique patterns. When we dig deeper, it's really 3–5 core patterns (web app, API backend, data pipeline, scheduled job) with variations.
>
> We start with the most common pattern. We get 70% of your teams covered with that one template. Then we add the next pattern. Eventually, you're covering 95% of your workloads with 5 curated patterns.
>
> For the truly edge-case use case (the one team that has a weird architecture), they can still provision manually or write custom IaC. But they're the exception, not the rule.
>
> The question isn't "does this work for every use case?" It's "does this dramatically improve the 80% that are standardized?" The answer is yes.

### "Our app teams won't adopt this. They like the freedom of IaC."

**Response:**

> That's a fair concern. But I'd ask: are they really happy writing Terraform? Or are they frustrated and slow?
>
> In my experience, the developers who **love** writing Terraform are a small percentage. Most app engineers want fast infrastructure. They don't care whether it comes from a template or custom IaC, as long as it's fast and works.
>
> When you show them "click a button, fill out 3 fields, get an environment in 2 minutes"—that's a better developer experience than "write Terraform, wait for review, fix issues, try again."
>
> We'd recommend piloting with one app team first. Let them try the self-service experience. Collect their feedback. Let that data inform whether you scale.

### "Won't this require a ton of platform team effort?"

**Response:**

> Actually, the opposite. The platform team effort is **front-loaded**, but then it scales.
>
> Week 1–4: Your platform team designs the first pattern and writes the Bicep template. Call it 40–60 hours of focused work.
>
> Week 5+: 50 app teams use that template without any platform team effort. You've essentially multiplied your platform team's output by 50x.
>
> Compare that to today: Your platform team is handling infrastructure tickets from every app team, every day. That's distributed, never-ending effort.
>
> This model is: concentrated, front-loaded effort on the template, then scale without ongoing friction.
>
> Once the first pattern is solid, adding a new pattern is much faster. You reuse the Bicep patterns, the governance controls, the documentation structure. The second pattern takes 1/3 the time.

---

## Copilot Integration Talking Points

**Use these when discussing GitHub Copilot as a productivity multiplier for platform teams**

### Template Development

> **GitHub Copilot for infrastructure templates:**
>
> Your platform engineers can use Copilot to write Bicep templates faster and with fewer bugs. Type a comment like "Create an App Service Plan with auto-scaling enabled," and Copilot generates the code. Not only faster, but it also educates new engineers on Bicep syntax.
>
> **Example conversation:**
> - Engineer: "How do I create a managed identity in Bicep?"
> - Copilot: [Generates the code with comments]
> - Engineer: "Now assign it this role..."
> - Copilot: [Generates the RBAC assignment with the correct role definition ID]

### Documentation

> **Copilot for documentation and runbooks:**
>
> When you publish an environment definition, you need documentation: "What is this environment? When should I use it? What parameters do I set?" Copilot can generate a first draft from a comment or outline. Your platform engineer reviews it, tweaks it, and publishes it. Saves 30–40% of documentation time.

### Governance Review

> **Copilot for template review:**
>
> When your platform team updates a Bicep template, you want to make sure the governance controls are still in place. Copilot can help you review: "List all the roles assigned in this template" or "Verify all resources have the required tags."

### Onboarding New Platform Engineers

> **Copilot for knowledge transfer:**
>
> When you hire a new platform engineer, Copilot can help them learn your patterns quickly. They can ask Copilot questions about your templates in natural language, and Copilot can explain them by referencing the actual code.

---

## Suggested Pilot Framing

**How to propose the pilot so customers are enthusiastic**

### Pilot Narrative

> "We're not asking you to bet the farm on this pattern. We're asking you to bet one pattern on one team for one month."
>
> Here's how we'd structure it:
>
> **Week 1 & 2: Design & Develop**
> - We pick one high-demand infrastructure pattern (web app is a good first choice).
> - We design the Bicep template with your security and platform teams.
> - We write the environment definition, parameters, and documentation.
> - We test locally.
>
> **Week 3: Deploy & Integrate**
> - We stand up Azure Dev Center in your subscription.
> - We connect the catalog repo.
> - We publish the environment definition.
> - We verify it shows up in the Developer Portal.
>
> **Week 4: Pilot Deployment**
> - We pick one trusted app team.
> - They self-service an environment using the portal.
> - We watch it work end to end.
> - We collect their feedback on developer experience, clarity, governance.
>
> **Week 5 & 6: Iterate**
> - Based on feedback, we refine the template.
> - We validate compliance and governance.
> - We create runbooks and train your platform team.
> - We document lessons learned.
>
> **Outcome:** You have a production-validated environment pattern. Your first app team has moved from "wait 2 weeks for infrastructure" to "provision in 2 minutes." You have proof of the value.
>
> **Next Steps:** Expand to more patterns and more teams based on demand.

### Success Metrics

Help customers define what success means:

> "How will you know this pilot is successful?"
>
> Some suggested metrics:
> - **Time to provision an environment:** Decreased from X days to minutes
> - **Developer satisfaction:** Survey results on self-service experience
> - **Governance coverage:** 100% of environments have correct RBAC and tags
> - **Platform team effort:** Reduced time spent handling infrastructure tickets
> - **Consistency:** All environments created from the template are identical in structure
> - **Audit readiness:** All governance and compliance controls are in place and verifiable

### Risk Mitigation

Address concerns about pilot risk:

> "What could go wrong? Here's how we mitigate:"
>
> - **Environments are isolated:** Each environment is in its own resource group. If something breaks, it doesn't affect other teams.
> - **We start small:** One pattern, one team. If it doesn't work, we iterate. We don't scale until we're confident.
> - **Governance is reviewable:** Your security team can audit every deployment. We're not doing anything hidden.
> - **Reversible:** If you decide this isn't the right pattern, you're not locked in. You can continue with manual provisioning.
> - **Resource limits:** We can set quotas and limits on the self-service portal to prevent runaway costs.

---

## Next Steps & Close

### Immediate Proposal

**If they're interested, propose this in the meeting:**

> "Here's what I'd like to do:
>
> 1. **Technical Working Session (Next week, 2 hours):** Gather your platform engineering and security teams. We dive into the architecture. We scope out which pattern to pilot. We answer technical questions.
>
> 2. **Proof of Concept (Following 2 weeks):** We stand up a Dev Center and catalog in your subscription. We publish one environment definition. We have your team test it. Make it real and low-risk.
>
> 3. **Pilot Planning (Week 4):** Once the POC is solid, we plan the enterprise pilot. Which app teams? What's the rollout? How do we measure success?
>
> Does that timeline work for you?"

### Key Takeaways to Reinforce

Before they leave the room, make sure they understand:

1. **This solves a real problem:** Fast infrastructure + centralized governance is possible.
2. **It's proven:** Enterprise customers are running this in production.
3. **The pilot is low-risk:** One pattern, one team, 4–6 weeks.
4. **There's a clear path to scale:** Once the pilot works, you expand.
5. **GitHub Copilot is a bonus:** Accelerates platform team productivity.

### Follow-Up Email Template

**Send this after the meeting:**

> Subject: Platform Engineering Catalog Pattern – Next Steps
>
> Hi [Name],
>
> Thank you for making time today. I really enjoyed walking through the platform engineering pattern with you.
>
> To recap what we discussed:
>
> - **Challenge:** Balancing developer velocity with infrastructure governance is hard. Today, teams choose one or the other.
> - **Solution:** Azure Deployment Environments + Curated Catalogs = fast self-service environments with governance baked in.
> - **Proof:** You'd pilot one pattern with one app team in 4–6 weeks.
>
> Next steps:
> 1. I'll send you a technical reference doc on the ADE architecture.
> 2. I'll propose a time for your technical team deep-dive (2 hours next week).
> 3. We'll schedule the POC kickoff after that.
>
> A few things I'd like you to think about before we meet:
> - Which infrastructure pattern is your highest-priority? (Web app, API, data pipeline, etc.)
> - Which app team would be the best pilot customer?
> - What does success look like in terms of metrics?
>
> Looking forward to building this with you.
>
> [Your name]

---

## Appendix: Talking Points Quick Reference

**2-minute version:** _See Executive Summary above_

**5-minute version:** _See Technical Walkthrough above_

**10-minute version:** Combine Executive Summary + Solution + Demo Part 1 & 2

**30-minute version:** Full Customer Presentation Flow above

---

**Last Updated:** June 3, 2026  
**Version:** 1.0  
**Designed for:** Contoso customer presentation
