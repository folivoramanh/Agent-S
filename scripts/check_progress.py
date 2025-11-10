#!/usr/bin/env python3
"""
OSWorld Progress Checker
Usage: python scripts/check_progress.py [result_dir]
"""

import os
import sys
import json
import glob
from collections import defaultdict
from datetime import datetime

def check_progress(result_dir="results_maverick_full"):
    """Check progress and calculate statistics"""
    
    base_path = os.path.join(result_dir, "pyautogui/screenshot")
    
    # Find model directory
    if not os.path.exists(base_path):
        print(f"❌ Result directory not found: {base_path}")
        return
    
    model_dirs = [d for d in os.listdir(base_path) if os.path.isdir(os.path.join(base_path, d))]
    if not model_dirs:
        print(f"❌ No model directories found in: {base_path}")
        return
    
    model_dir = os.path.join(base_path, model_dirs[0])
    
    print("=" * 70)
    print(f"  📊 OSWorld Progress Report")
    print(f"  📁 Directory: {result_dir}")
    print(f"  🤖 Model: {model_dirs[0]}")
    print(f"  🕐 Time: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)
    print()
    
    domain_stats = defaultdict(lambda: {"total": 0, "success": 0, "failed": 0, "in_progress": 0})
    
    # Count all task directories
    for domain in os.listdir(model_dir):
        domain_path = os.path.join(model_dir, domain)
        if not os.path.isdir(domain_path):
            continue
        
        for example in os.listdir(domain_path):
            example_path = os.path.join(domain_path, example)
            if not os.path.isdir(example_path):
                continue
            
            result_file = os.path.join(example_path, "result.txt")
            
            if os.path.exists(result_file):
                # Task completed
                domain_stats[domain]["total"] += 1
                try:
                    with open(result_file) as f:
                        score = float(f.read().strip())
                        if score > 0:
                            domain_stats[domain]["success"] += 1
                        else:
                            domain_stats[domain]["failed"] += 1
                except:
                    domain_stats[domain]["failed"] += 1
            else:
                # Check if task is in progress
                screenshots = glob.glob(os.path.join(example_path, "step_*.png"))
                if screenshots:
                    domain_stats[domain]["in_progress"] += 1
    
    # Print per-domain statistics
    print(f"{'Domain':<20} {'Complete':<10} {'Success':<10} {'Failed':<10} {'In Progress':<12} {'Rate':<10}")
    print("-" * 70)
    
    total_complete = 0
    total_success = 0
    total_failed = 0
    total_in_progress = 0
    
    for domain in sorted(domain_stats.keys()):
        stats = domain_stats[domain]
        complete = stats["total"]
        success = stats["success"]
        failed = stats["failed"]
        in_prog = stats["in_progress"]
        
        if complete > 0:
            rate = success / complete * 100
            rate_str = f"{rate:.1f}%"
        else:
            rate_str = "N/A"
        
        print(f"{domain:<20} {complete:<10} {success:<10} {failed:<10} {in_prog:<12} {rate_str:<10}")
        
        total_complete += complete
        total_success += success
        total_failed += failed
        total_in_progress += in_prog
    
    print("-" * 70)
    
    # Overall statistics
    if total_complete > 0:
        overall_rate = total_success / total_complete * 100
        overall_rate_str = f"{overall_rate:.2f}%"
    else:
        overall_rate_str = "N/A"
    
    print(f"{'OVERALL':<20} {total_complete:<10} {total_success:<10} {total_failed:<10} {total_in_progress:<12} {overall_rate_str:<10}")
    print("=" * 70)
    
    # Summary
    print()
    print("📈 Summary:")
    print(f"   ✅ Completed Tasks: {total_complete}")
    print(f"   🎯 Successful: {total_success} ({overall_rate_str})")
    print(f"   ❌ Failed: {total_failed}")
    print(f"   ⏳ In Progress: {total_in_progress}")
    
    # Estimate remaining
    if total_complete > 0:
        print()
        print("💡 Estimates:")
        print(f"   Expected success rate: {overall_rate_str}")
        if total_in_progress > 0:
            estimated_success = int(total_in_progress * (overall_rate / 100))
            print(f"   Estimated additional successes: {estimated_success}/{total_in_progress}")
    
    print()

if __name__ == "__main__":
    result_dir = sys.argv[1] if len(sys.argv) > 1 else "results_maverick_full"
    check_progress(result_dir)

