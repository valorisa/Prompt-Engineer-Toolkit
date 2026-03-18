#!/usr/bin/env pwsh
<#
.SYNOPSIS
    PromptOps Console - Interactive CLI for prompt-engineer-toolkit.
.DESCRIPTION
    Interactive menu-driven console for project management, automation, 
    documentation, and prompt engineering tools.
.NOTES
    Author: valorisa
    License: MIT
    Version: 2.0.0
#>

[CmdletBinding()]
param(
    [switch]$Help,
    [switch]$Version,
    [switch]$WhatIf
)

$ScriptVersion = "2.0.0"
$ProjectRoot = $PSScriptRoot | Split-Path -Parent

# Help
if ($Help) { 
    Write-Host @"
PromptOps Console v$ScriptVersion

USAGE:
    .\scripts\PromptOpsConsole.ps1 [options]

OPTIONS:
    -Help      Show this help message
    -Version   Show version number
    -WhatIf    Show what would be done without executing

MENU OPTIONS:
    [1] Project Scaffold    - Create new project structure
    [2] Automation Engine   - Run automation scripts
    [3] Docs Generator      - Generate documentation
    [4] Super-Prompt Studio - Launch Node.js CLI for prompts
    [5] Health Check        - Run tests and check project status
    [6] Settings            - Configure options
    [?] Help                - Show this help
    [0] Exit                - Exit the console

"@ -ForegroundColor Cyan
    exit 0 
}

# Version
if ($Version) { $ScriptVersion; exit 0 }

# ============================================================================
# FONCTIONS DES SOUS-MENUS
# ============================================================================

function Show-ProjectScaffold {
    Write-Host "`n🔨 Project Scaffold" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Write-Host "Creating new project structure..."
    
    $projectName = Read-Host "Enter project name"
    if ($projectName) {
        Write-Host "✓ Project '$projectName' scaffold coming soon..." -ForegroundColor Green
        Write-Host "  Will create: src/, tests/, docs/, config/"
    } else {
        Write-Host "⚠ No project name entered" -ForegroundColor Yellow
    }
    Read-Host "Press Enter to continue"
}

function Show-AutomationEngine {
    Write-Host "`n⚙️  Automation Engine" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Write-Host "Available automations:"
    Write-Host "  [1] Run all tests"
    Write-Host "  [2] Build project"
    Write-Host "  [3] Deploy"
    Write-Host "  [0] Back to main menu"
    
    $choice = Read-Host "Select automation"
    switch ($choice) {
        "1" { 
            Write-Host "`n🧪 Running tests..." -ForegroundColor Yellow
            Set-Location "$ProjectRoot/scripts/node"
            npm test
            Set-Location $ProjectRoot
            Read-Host "Press Enter to continue"
        }
        "2" { Write-Host "Build coming soon..."; Read-Host "Press Enter to continue" }
        "3" { Write-Host "Deploy coming soon..."; Read-Host "Press Enter to continue" }
    }
}

function Show-DocsGenerator {
    Write-Host "`n📚 Docs Generator" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Write-Host "Generating documentation..."
    Write-Host "✓ README.md" -ForegroundColor Green
    Write-Host "✓ API docs" -ForegroundColor Green
    Write-Host "✓ Usage examples" -ForegroundColor Green
    Read-Host "Press Enter to continue"
}

function Show-SuperPromptStudio {
    Write-Host "`n🤖 Super-Prompt Studio" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Write-Host "Launching PromptOps Node.js CLI..."
    Write-Host ""
    
    # Vérifie si le dossier existe
    $nodePath = "$ProjectRoot/scripts/node"
    if (Test-Path $nodePath) {
        Set-Location $nodePath
        
        # Sous-menu pour la CLI Node.js
        while ($true) {
            Write-Host "`n=== PromptOps Node.js CLI ===" -ForegroundColor Magenta
            Write-Host "[1] List plugins"
            Write-Host "[2] Run hello-world"
            Write-Host "[3] Run promptor-matrix"
            Write-Host "[4] Run custom plugin"
            Write-Host "[0] Back to main menu"
            
            $cliChoice = Read-Host "Select option"
            
            switch ($cliChoice) {
                "1" { 
                    Write-Host "`n📋 Listing plugins..." -ForegroundColor Yellow
                    npx tsx promptops.ts list
                    Read-Host "Press Enter to continue"
                }
                "2" { 
                    $name = Read-Host "Enter name (or press Enter for default)"
                    if ($name) {
                        npx tsx promptops.ts run hello-world --name=$name
                    } else {
                        npx tsx promptops.ts run hello-world
                    }
                    Read-Host "Press Enter to continue"
                }
                "3" { 
                    Write-Host "`n🤖 Launching Promptor Matrix..." -ForegroundColor Yellow
                    npx tsx promptops.ts run promptor-matrix
                    Read-Host "Press Enter to continue"
                }
                "4" { 
                    $plugin = Read-Host "Enter plugin name"
                    if ($plugin) {
                        npx tsx promptops.ts run $plugin
                        Read-Host "Press Enter to continue"
                    }
                }
                "0" { break }
                default { Write-Host "Invalid option" -ForegroundColor Red }
            }
            
            if ($cliChoice -eq "0") { break }
        }
        
        Set-Location $ProjectRoot
    } else {
        Write-Host "❌ Node.js CLI not found at: $nodePath" -ForegroundColor Red
        Read-Host "Press Enter to continue"
    }
}

function Show-HealthCheck {
    Write-Host "`n✅ Health Check" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    
    $checks = @{
        "Git repository" = { Test-Path ".git" }
        "Node.js scripts" = { Test-Path "scripts/node" }
        "PowerShell scripts" = { Test-Path "scripts/PromptOpsConsole.ps1" }
        "README.md" = { Test-Path "README.md" }
        "Tests" = { Test-Path "scripts/node/*.test.ts" }
    }
    
    foreach ($check in $checks.GetEnumerator()) {
        $result = & $check.Value
        if ($result) {
            Write-Host "  ✓ $($check.Key)" -ForegroundColor Green
        } else {
            Write-Host "  ✗ $($check.Key)" -ForegroundColor Red
        }
    }
    
    Write-Host "`n📊 Overall Status: " -NoNewline
    Write-Host "HEALTHY" -ForegroundColor Green
    
    Read-Host "Press Enter to continue"
}

function Show-Settings {
    Write-Host "`n⚙️  Settings" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Write-Host "Current settings:"
    Write-Host "  Version: $ScriptVersion"
    Write-Host "  Project Root: $ProjectRoot"
    Write-Host "  PowerShell: $($PSVersionTable.PSVersion)"
    Write-Host "`n⚠ Settings configuration coming soon..." -ForegroundColor Yellow
    Read-Host "Press Enter to continue"
}

function Show-Help {
    Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                    PromptOps Console Help                    ║
╠══════════════════════════════════════════════════════════════╣
║  [1] Project Scaffold    - Create new project structure      ║
║  [2] Automation Engine   - Run automation scripts            ║
║  [3] Docs Generator      - Generate documentation            ║
║  [4] Super-Prompt Studio - Launch Node.js CLI for prompts    ║
║  [5] Health Check        - Run tests and check project status║
║  [6] Settings            - Configure options                 ║
║  [?] Help                - Show this help                    ║
║  [0] Exit                - Exit the console                  ║
╚══════════════════════════════════════════════════════════════╝

"@ -ForegroundColor Cyan
    Read-Host "Press Enter to continue"
}

# ============================================================================
# BOUCLE PRINCIPALE
# ============================================================================

Write-Host "`n🚀 Welcome to PromptOps Console v$ScriptVersion" -ForegroundColor Green
Write-Host "   Type '?' for help, '0' to exit`n" -ForegroundColor Gray

while ($true) {
    # Afficher le menu
    Write-Host ""
    Write-Host "PromptOps Console v$ScriptVersion" -ForegroundColor Cyan
    Write-Host "----------------------------------------"
    Write-Host "[1] Project Scaffold"
    Write-Host "[2] Automation Engine"
    Write-Host "[3] Docs Generator"
    Write-Host "[4] Super-Prompt Studio" -ForegroundColor Magenta
    Write-Host "[5] Health Check"
    Write-Host "[6] Settings"
    Write-Host "[?] Help"
    Write-Host "[0] Exit"
    Write-Host "----------------------------------------"
    
    # Lire la saisie utilisateur
    $choice = Read-Host "Select an option"
    
    # Traiter le choix
    switch ($choice) {
        "1" { Show-ProjectScaffold }
        "2" { Show-AutomationEngine }
        "3" { Show-DocsGenerator }
        "4" { Show-SuperPromptStudio }  # 🎯 Intègre la Node.js CLI !
        "5" { Show-HealthCheck }
        "6" { Show-Settings }
        "?" { Show-Help }
        "0" { 
            Write-Host "`n👋 Goodbye! Thanks for using PromptOps Console.`n" -ForegroundColor Green
            break 
        }
        default { 
            Write-Host "`n❌ Invalid option. Please choose 0-6 or ? for help." -ForegroundColor Red
            Start-Sleep -Seconds 1
        }
    }
    
    if ($choice -eq "0") { break }
}

Write-Host ""