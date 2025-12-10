# Sync to GitHub Script
# Syncs this folder to: https://github.com/tttn0000/bienphiendoan-tools

$ErrorActionPreference = "Stop"
$repoUrl = "https://github.com/tttn0000/bienphiendoan-tools.git"
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Change to the script directory
Push-Location $scriptDir

try {
   # Check if git is initialized
   if (-not (Test-Path ".git")) {
      Write-Host "Initializing git repository..." -ForegroundColor Cyan
      git init
      git branch -M main
        
      # Add remote
      Write-Host "Adding remote origin..." -ForegroundColor Cyan
      git remote add origin $repoUrl
   }
   else {
      Write-Host "Git repository already initialized." -ForegroundColor Green
        
      # Check if remote exists, if not add it
      $remotes = git remote
      if ($remotes -notcontains "origin") {
         Write-Host "Adding remote origin..." -ForegroundColor Cyan
         git remote add origin $repoUrl
      }
      else {
         # Update remote URL if needed
         $currentUrl = git remote get-url origin
         if ($currentUrl -ne $repoUrl) {
            Write-Host "Updating remote URL..." -ForegroundColor Yellow
            git remote set-url origin $repoUrl
         }
      }
   }

   # Pull latest changes first (if repo exists remotely)
   Write-Host "`nAttempting to pull latest changes..." -ForegroundColor Cyan
   try {
      git fetch origin main 2>$null
      git pull origin main --allow-unrelated-histories 2>$null
   }
   catch {
      Write-Host "No existing remote content to pull (new repository)" -ForegroundColor Yellow
   }

   # Stage all changes
   Write-Host "`nStaging changes..." -ForegroundColor Cyan
   git add -A

   # Check if there are changes to commit
   $status = git status --porcelain
   if ($status) {
      # Auto-generate commit message with timestamp
      $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
      $commitMessage = "Sync update - $timestamp"
        
      Write-Host "`nChanges detected:" -ForegroundColor Yellow
      git status --short

      # Commit
      Write-Host "`nCommitting changes..." -ForegroundColor Cyan
      git commit -m $commitMessage

      # Push
      Write-Host "`nPushing to GitHub..." -ForegroundColor Cyan
      git push -u origin main

      Write-Host "`n✓ Successfully synced to GitHub!" -ForegroundColor Green
   }
   else {
      Write-Host "`nNo changes to commit. Repository is up to date." -ForegroundColor Green
   }

}
catch {
   Write-Host "`n✗ Error: $_" -ForegroundColor Red
   exit 1
}
finally {
   Pop-Location
}

Write-Host "`nPress any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
