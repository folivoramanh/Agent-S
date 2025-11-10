# OSWorld Management Scripts

Bộ scripts hỗ trợ quản lý và monitor OSWorld tests.

## 📁 Scripts Available

### 1. `run_full_test.sh` - Chạy Full Test
Chạy OSWorld test với các options khác nhau.

```bash
# Chạy small test (50 tasks, ~4-12h)
./scripts/run_full_test.sh small

# Chạy full test (300 tasks, ~25-75h)
./scripts/run_full_test.sh full

# Chạy specific domain
./scripts/run_full_test.sh chrome
./scripts/run_full_test.sh gimp
```

### 2. `monitor.sh` - Live Monitor
Monitor real-time progress, resources, và Docker status.

```bash
# Monitor với auto-detect result dir
./scripts/monitor.sh

# Monitor specific result dir
./scripts/monitor.sh results_maverick_small
```

**Hiển thị:**
- ✅ Tasks completed
- 📊 Success rate
- 🐳 Docker containers
- 💾 Disk usage
- 🖥️ System resources
- 📈 Recent logs

### 3. `check_progress.py` - Detailed Progress Report
Chi tiết progress theo từng domain với statistics.

```bash
# Check default result dir
python scripts/check_progress.py

# Check specific result dir
python scripts/check_progress.py results_maverick_full
```

**Output:**
- Per-domain statistics
- Success/failure rates
- In-progress tasks
- Overall summary

### 4. `backup_results.sh` - Backup Results
Backup results (không bao gồm screenshots để tiết kiệm space).

```bash
# Backup default result dir
./scripts/backup_results.sh

# Backup specific result dir
./scripts/backup_results.sh results_maverick_full
```

**Features:**
- Excludes large files (*.png, *.mp4)
- Creates backup manifest
- Auto-cleanup (keeps last 5 backups)

### 5. `stop_test.sh` - Stop Running Test
Gracefully stop một running test.

```bash
# Stop using PID file
./scripts/stop_test.sh run_full.pid

# List available PID files if none specified
./scripts/stop_test.sh
```

**Process:**
1. Send SIGTERM (graceful)
2. Wait 30 seconds
3. Force kill if needed
4. Cleanup Docker containers

### 6. `resume_test.sh` - Resume Interrupted Test
Resume một test bị interrupt (auto-skip completed tasks).

```bash
# List available result dirs if none specified
./scripts/resume_test.sh

# Resume specific test
./scripts/resume_test.sh results_maverick_full
```

**Features:**
- Reads previous configuration
- Skips completed tasks
- Continues from where it stopped

### 7. `check_errors.sh` - Check Log Errors
Scan logs for errors, exceptions, và warnings.

```bash
# Check all logs
./scripts/check_errors.sh

# Check specific log
./scripts/check_errors.sh logs/run_full_*.log
```

## 🚀 Quick Start Workflow

### Chạy Full Test lần đầu:

```bash
# 1. Start test
./scripts/run_full_test.sh full

# 2. Monitor trong terminal khác
./scripts/monitor.sh results_maverick_full_*

# 3. Check detailed progress
python scripts/check_progress.py results_maverick_full_*

# 4. Backup định kỳ (optional)
./scripts/backup_results.sh results_maverick_full_*
```

### Nếu bị interrupt:

```bash
# Resume test
./scripts/resume_test.sh results_maverick_full_*
```

### Check for issues:

```bash
# Check errors
./scripts/check_errors.sh

# Monitor logs
tail -f logs/run_full_*.log
```

## 🔧 Setup

Make all scripts executable:

```bash
chmod +x scripts/*.sh
```

## 📊 Recommended Monitoring Schedule

### Terminal 1: Run test
```bash
./scripts/run_full_test.sh full
```

### Terminal 2: Monitor
```bash
./scripts/monitor.sh results_maverick_full_*
```

### Terminal 3: Periodic checks
```bash
# Every hour
watch -n 3600 'python scripts/check_progress.py results_maverick_full_*'

# Every 6 hours - backup
watch -n 21600 './scripts/backup_results.sh results_maverick_full_*'
```

## 💡 Tips

1. **Use tmux/screen** để avoid session disconnect:
   ```bash
   tmux new -s osworld
   ./scripts/run_full_test.sh full
   # Detach: Ctrl+B, D
   # Reattach: tmux attach -t osworld
   ```

2. **Regular backups** (mỗi 6-12h):
   ```bash
   crontab -e
   # Add: 0 */6 * * * cd /localhome/local-amtrinh/OSWorld && ./scripts/backup_results.sh results_maverick_full_*
   ```

3. **Monitor errors**:
   ```bash
   # Check errors mỗi 30 phút
   watch -n 1800 './scripts/check_errors.sh'
   ```

4. **Disk space warning**:
   ```bash
   # Alert khi < 50GB
   df -h / | awk '$4 < 50 {print "⚠️ Low disk space: "$4" available"}'
   ```

## 🆘 Troubleshooting

### Script không chạy:
```bash
chmod +x scripts/*.sh
```

### Python script không tìm thấy modules:
```bash
conda activate osworld
python scripts/check_progress.py
```

### Docker containers dư thừa:
```bash
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
```

### Log quá lớn:
```bash
# Compress old logs
gzip logs/run_*.log
```

