# Tmux

## 安装
```bash
./install.sh
```

## 使用方式
- Prefix Key: `Ctrl + a`

| 快捷键 | 功能 |
| -------- | -------- |
| `<prefix>` + `c` | 開啟新視窗 |
| `<prefix>` + `w` | 列出所有視窗 |
| `<prefix>` + `%` | 水平分割視窗 |
| `<prefix>` + `'` | 垂直分割視窗 |
| `<prefix>` + `方向鍵` | 切換視窗 |
| `<prefix>` + `z` | 切換當前視窗大小 |
| `<prefix>` + `&` | 關閉當前視窗 |
| `<prefix>` + `,` | 重命名當前視窗 |
| `<prefix>` + `:` | 進入命令模式 |
| `<prefix>` + `[` | 進入複製模式 |
| `<prefix>` + `]` | 粘貼複製的內容 |
| `<prefix>` + `d` | 分離當前會話 |
| `<prefix>` + `空格` | 切換窗格布局 |
| `<prefix>` + `!` | 將當前窗格分離為新視窗 |
| `<prefix>` + `?` | 查看所有快捷鍵 |
| `<prefix>` + `$` | 重新命名當前群組 |
| `<prefix>` + `m` | 切換滑鼠模式 |
| `<prefix>` + `r` | 重新載入設定 |


- 創建新群組:
    ```bash
    tmux new-session -s <another_session>
    ```