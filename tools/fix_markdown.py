#!/usr/bin/env python3
"""
Auto-fix common markdown linting issues
"""

import re
from pathlib import Path


def fix_trailing_spaces(content):
    """Fix trailing spaces (MD009)"""
    lines = content.split('\n')
    fixed_lines = []
    for line in lines:
        # Remove trailing spaces unless they are exactly 2 (which is valid for line breaks)
        stripped = line.rstrip()
        if line.endswith('  ') and not line.endswith('   '):
            # Keep intentional line breaks
            fixed_lines.append(stripped + '  ')
        else:
            fixed_lines.append(stripped)
    return '\n'.join(fixed_lines)

def fix_multiple_blank_lines(content):
    """Fix multiple consecutive blank lines (MD012)"""
    # Replace multiple consecutive blank lines with single blank line
    return re.sub(r'\n\n\n+', '\n\n', content)

def fix_fenced_code_blocks(content):
    """Add blank lines around fenced code blocks (MD031)"""
    lines = content.split('\n')
    fixed_lines = []
    
    for i, line in enumerate(lines):
        if line.strip().startswith('```'):
            # Check if this is opening or closing fence
            if '```' in line and line.strip() != '```' and not line.strip().startswith('```'):
                # This might be an inline code or malformed
                fixed_lines.append(line)
                continue
                
            prev_line = lines[i-1] if i > 0 else ""
            next_line = lines[i+1] if i < len(lines) - 1 else ""
            
            # Add blank line before opening fence
            if line.strip().startswith('```') and len(line.strip()) > 3:  # Opening fence
                if prev_line.strip() != "" and not prev_line.strip().startswith('#'):
                    if i > 0 and not fixed_lines[-1] == "":
                        fixed_lines.append("")
                fixed_lines.append(line)
            # Add blank line after closing fence  
            elif line.strip() == '```':  # Closing fence
                fixed_lines.append(line)
                if next_line.strip() != "" and i < len(lines) - 1:
                    fixed_lines.append("")
            else:
                fixed_lines.append(line)
        else:
            fixed_lines.append(line)
    
    return '\n'.join(fixed_lines)

def fix_headings_spacing(content):
    """Add blank lines around headings (MD022)"""
    lines = content.split('\n')
    fixed_lines = []
    
    for i, line in enumerate(lines):
        if line.strip().startswith('#') and not line.strip().startswith('#include'):
            prev_line = lines[i-1] if i > 0 else ""
            next_line = lines[i+1] if i < len(lines) - 1 else ""
            
            # Add blank line before heading (except at start of file)
            if i > 0 and prev_line.strip() != "":
                if not fixed_lines[-1] == "":
                    fixed_lines.append("")
            
            fixed_lines.append(line)
            
            # Add blank line after heading (except at end of file)
            if i < len(lines) - 1 and next_line.strip() != "":
                fixed_lines.append("")
        else:
            fixed_lines.append(line)
    
    return '\n'.join(fixed_lines)

def fix_lists_spacing(content):
    """Add blank lines around lists (MD032)"""
    lines = content.split('\n')
    fixed_lines = []
    
    for i, line in enumerate(lines):
        # Detect list items
        if re.match(r'^[\s]*[-*+]\s', line) or re.match(r'^[\s]*\d+\.\s', line):
            prev_line = lines[i-1] if i > 0 else ""
            
            # Check if this is the first item in a list
            if i > 0 and not re.match(r'^[\s]*[-*+]\s', prev_line) and not re.match(r'^[\s]*\d+\.\s', prev_line):
                if prev_line.strip() != "":
                    if not fixed_lines[-1] == "":
                        fixed_lines.append("")
            
            fixed_lines.append(line)
            
            # Check if this is the last item in a list
            next_line = lines[i+1] if i < len(lines) - 1 else ""
            if i < len(lines) - 1:
                if not re.match(r'^[\s]*[-*+]\s', next_line) and not re.match(r'^[\s]*\d+\.\s', next_line):
                    if next_line.strip() != "":
                        fixed_lines.append("")
        else:
            fixed_lines.append(line)
    
    return '\n'.join(fixed_lines)

def fix_single_trailing_newline(content):
    """Ensure file ends with single newline (MD047)"""
    content = content.rstrip()
    return content + '\n'

def fix_markdown_file(file_path):
    """Fix a single markdown file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Apply fixes in order
        content = fix_trailing_spaces(content)
        content = fix_multiple_blank_lines(content)
        content = fix_single_trailing_newline(content)
        
        # Write back only if changed
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"✅ Fixed: {file_path}")
            return True
        else:
            print(f"⏭️  No changes: {file_path}")
            return False
    except Exception as e:
        print(f"❌ Error fixing {file_path}: {e}")
        return False

def main():
    workspace_root = Path(__file__).parent.parent
    
    # Find all markdown files
    markdown_files = []
    
    # Include specific directories
    for pattern in ['_posts/*.md', '_drafts/*.md', 'docs/*.md', '*.md', '_plugins/*.md']:
        markdown_files.extend(workspace_root.glob(pattern))
    
    # Filter out excluded directories
    excluded_dirs = {'.venv', 'node_modules', '_site', '.devbox', '.git', '.terraform', 'vendor', '.bundle'}
    
    markdown_files = [
        f for f in markdown_files 
        if not any(part in excluded_dirs for part in f.parts)
    ]
    
    print(f"Found {len(markdown_files)} markdown files to process")
    
    fixed_count = 0
    for file_path in markdown_files:
        if fix_markdown_file(file_path):
            fixed_count += 1
    
    print(f"\n🎉 Fixed {fixed_count} files out of {len(markdown_files)} total files")

if __name__ == "__main__":
    main()
