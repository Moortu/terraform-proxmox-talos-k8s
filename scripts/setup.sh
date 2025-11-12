#!/bin/bash
# Setup script for terraform-proxmox-talos-k8s
# This creates the necessary .auto.tfvars files for deployment

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
STACKS_DIR="$PROJECT_ROOT/stacks/production"

echo "Setting up terraform-proxmox-talos-k8s..."
echo ""

# Check if production.auto.tfvars exists
if [ ! -f "$STACKS_DIR/production.auto.tfvars" ]; then
    echo "❌ Error: $STACKS_DIR/production.auto.tfvars not found"
    echo ""
    echo "Please create it first:"
    echo "  cp $PROJECT_ROOT/example.tfvars $STACKS_DIR/production.auto.tfvars"
    echo "  nano $STACKS_DIR/production.auto.tfvars"
    exit 1
fi

echo "✅ Found production.auto.tfvars"
echo ""

# Create empty terraform.tfvars files in each stack
# These will be ignored by git, but allow each stack to load parent variables
for stack_dir in "$STACKS_DIR"/*/ ; do
    if [ -d "$stack_dir" ]; then
        stack_name=$(basename "$stack_dir")
        tfvars_file="$stack_dir/terraform.tfvars"
        
        if [ ! -f "$tfvars_file" ]; then
            touch "$tfvars_file"
            echo "✅ Created $stack_name/terraform.tfvars"
        fi
    fi
done

echo ""
echo "✅ Setup complete!"
echo ""
echo "Next steps:"
echo "  1. Verify your configuration: nano $STACKS_DIR/production.auto.tfvars"
echo "  2. Generate Terramate code: terramate generate"
echo "  3. Deploy: terramate run tofu apply"
echo ""
