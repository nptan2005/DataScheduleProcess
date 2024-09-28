# Dự án Scheduler Service

## Tổng quan
Dự án này xử lý việc lên lịch, thực thi và lưu trữ dữ liệu sau khi xử lý. Nó tích hợp với cơ sở dữ liệu Oracle, các server SFTP và dịch vụ email.

### Cấu trúc thư mục
TaskService/
|__ Archived/
|__ Data/
|__ configurable/
|__ bin/
|__ core/
|   |__ conn_kit/
|   |__ core_config/
|   |__ data_kit/
|   |__ ISO8583Message/
|   |__ multiAlgoCoder/
|   |__ utilities/
|__ externalTaskModule/
|__ task_flow/
|   |__ model/
|   |__ task_data/
|   |__ task_business/
|   |__ task_engine/
|   |__ task_queue/
|   |__ taskController.py
|   |__ taskDispatcher.py
|   |__ taskProcessor.py
|   |__ taskScheduler.py
|__ main.py
|__ encode_password.py
|__ test_job.py
|__ pyproject.toml



SchedulerService/
│
├── core/
│   ├── conn_kit/
│   │   ├── src/
│   │   │   ├── connKitConstant.py
│   │   └── __init__.py
│   ├── data_kit/
│   │   ├── src/
│   │   │   ├── dataConstant.py
│   │   └── __init__.py
│   └── __init__.py
└── __init__.py


SchedulerService/
│
├── core/
│   ├── conn_kit/
│   │   ├── src/
│   │   │   ├── __init__.py
│   │   │   ├── connKitConstant.py
│   │   └── pyproject.toml
│   ├── data_kit/
│   │   ├── src/
│   │   │   ├── __init__.py
│   │   │   ├── dataConstant.py
│   │   └── pyproject.toml
│   ├── utilities/
│   │   ├── src/
│   │   │   ├── __init__.py
│   │   └── pyproject.toml
│   ├── core_config/
│   │   ├── src/
│   │   │   ├── __init__.py
│   │   └── pyproject.toml
│   └── __init__.py
└── pyproject.toml



- **Logs**: Lưu trữ log của ứng dụng.
- **Archived**: Lưu trữ dữ liệu sau khi xử lý.
  - `Archived_Attachment`: Lưu trữ email.
  - `Archived_Export`, `Archived_Import`, `Archived_SFTP`: Lưu trữ các dữ liệu khác.
- **Data**: Lưu trữ tạm thời dữ liệu trong quá trình xử lý.
  - `Attachment_Data`, `Export_Data`, `Import_Data`: Chứa dữ liệu của các tác vụ tương ứng.
- **SchedulerService**: Mã nguồn chính của dự án.
  - `bin`: Lưu trữ các khóa mã hóa và dữ liệu đã mã hóa.
  - `configurable`: Các file config và script load config.
  - `conn_kit`: Module xử lý kết nối bên ngoài (SFTP, email).
  - `data_kit`: Các tiện ích xử lý dữ liệu.
  - `db_conn`: Kết nối với cơ sở dữ liệu Oracle.
  - `externalTaskModule`: Các module xử lý tác vụ bên ngoài.
  - `multiAlgoCoder`: Xử lý logic mã hóa.
  - `task_flow`: Điều phối lịch trình và thực thi các tác vụ.

## Cài đặt
### Yêu cầu hệ thống
- **Python 3.x**: Để chạy các script Python.
- **Poetry**: Để quản lý các thư viện.
- **Oracle Database**: Cho kết nối tới cơ sở dữ liệu.
- **Linux OS**: Chạy hệ thống backend trên máy chủ Linux.

## Hướng dẫn cài đặt
### Bước 1: Cài đặt các thư viện phụ thuộc
1. **Cài đặt Python**:
   Trên hệ thống Linux, cài Python và pip:
   ```bash
   sudo apt-get update
   sudo apt-get install python3 python3-pip

2. **Cài poetry**:
    curl -sSL https://install.python-poetry.org | python3 -
    export PATH="$HOME/.local/bin:$PATH"
    poetry --version

3. **Tao folder chuong trinh**:
   mkdir ~/TaskService
   cd ~/TaskService
   scp -r D:\WorkSpace\Python\release\TaskService tannp@172.27.5.35:/home/tannp/Task_Tests/
4. **Copy Source**:
   scp dist/task_flow-0.1.0.tar.gz tannp@172.27.5.35:~/TaskService
   scp dist/task_flow-0.1.0-py3-none-any.whl tannp@172.27.5.35:~/TaskService
5. **Tao moi truong ao**:
   python -m venv venv
   source venv/bin/activate
6. **Cai dat**:
    pip install /home/tannp/Task_Tests/TaskService/dist/task_flow_service-0.1.0.tar.gz

   pip install ~/Source_Release/task_flow-0.1.0.tar.gz




7. **init library**:
    cd /home/tannp/TaskService
    poetry install
8. **Kích hoạt môi trường ảo**:
    poetry shell
9. **Thiết lập CSDL**:


10. **Cài back-end Service**:
    a. ***tạo file***:
        sudo nano /etc/systemd/system/task_shedule_service.service
    b. ***Nội dung***:
        [Unit]
        Description=Task Schedule Service
        After=network.target

        [Service]
        User=tannp
        Group=tannp
        WorkingDirectory=/home/tannp/TaskService
        ExecStart=/home/tannp/TaskService/venv/bin/poetry run python /home/tannp/TaskService/main.py
        Restart=always

        [Install]
        WantedBy=multi-user.target
    c. ***Khởi động và kích hoạt dịch vụ***:
        sudo systemctl daemon-reload
        sudo systemctl enable task_shedule_service
        sudo systemctl start task_shedule_service
    d. ***Kiểm tra trạng thái dịch vụ***:
        sudo systemctl status task_shedule_service
11. **Phân quyền**:
    # Thư mục Logs (quyền đọc/ghi)
    mkdir -p ~/Logs
    chmod 755 ~/Logs

    # Thư mục Archived (quyền đọc/ghi)
    mkdir -p ~//Archived/Archived_Attachment
    mkdir -p ~/Archived/Archived_Export
    mkdir -p ~/to/Archived/Archived_Import
    mkdir -p ~/Archived/Archived_SFTP
    chmod -R 755 ~/Archived

    # Thư mục Data (quyền đọc/ghi/xóa)
    mkdir -p ~/Data/Attachment_Data
    mkdir -p ~/Data/Export_Data
    mkdir -p ~/Data/Import_Data
    chmod -R 777 ~/to/Data

    # Thư mục TaskService
    chmod -R 755 ~/TaskService

12. **Yeu cau mo allow sftp**:
13. **Yeu cau allow connect database**:
14. **Cai Dat Oracle CLient**:
15. **Yeu cau trust IP to email server**:






