
CREATE DATABASE student_project_management;

-- Kết nối đến database và tạo các bảng
USE student_project_management;

-- 1. Bảng Khoa (Departments)
CREATE TABLE departments (
    department_id INT IDENTITY(1,1) PRIMARY KEY,
    department_code NVARCHAR(10) NOT NULL UNIQUE,
    department_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE()
);

-- 2. Bảng Ngành học (Majors)
CREATE TABLE majors (
    major_id INT IDENTITY(1,1) PRIMARY KEY,
    major_code NVARCHAR(10) NOT NULL UNIQUE,
    major_name NVARCHAR(200) NOT NULL,
    department_id INT NOT NULL,
    description NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 3. Bảng Lớp (Classes)
CREATE TABLE classes (
    class_id INT IDENTITY(1,1) PRIMARY KEY,
    class_code NVARCHAR(20) NOT NULL UNIQUE,
    class_name NVARCHAR(100) NOT NULL,
    major_id INT NOT NULL,
    academic_year NVARCHAR(20) NOT NULL, -- Ví dụ: "2020-2024"
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (major_id) REFERENCES majors(major_id)
);

-- 4. Bảng Người dùng (Users) - Bao gồm sinh viên, giảng viên, admin
CREATE TABLE users (
    user_id INT IDENTITY(1,1) PRIMARY KEY,
    username NVARCHAR(50) NOT NULL UNIQUE,
    email NVARCHAR(100) NOT NULL UNIQUE,
    password_hash NVARCHAR(255) NOT NULL,
    full_name NVARCHAR(200) NOT NULL,
    phone NVARCHAR(20),
    role NVARCHAR(20) NOT NULL,
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    CONSTRAINT chk_role CHECK (role IN ('admin', 'teacher', 'student'))
);

-- 5. Bảng Sinh viên (Students)
CREATE TABLE students (
    student_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    student_code NVARCHAR(20) NOT NULL UNIQUE,
    class_id INT NOT NULL,
    enrollment_year INT NOT NULL,
    gpa DECIMAL(3,2) DEFAULT 0.00,
    status NVARCHAR(20) DEFAULT 'active',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (class_id) REFERENCES classes(class_id),
    CONSTRAINT chk_status CHECK (status IN ('active', 'suspended', 'graduated'))
);

-- 6. Bảng Giảng viên (Teachers)
CREATE TABLE teachers (
    teacher_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    teacher_code NVARCHAR(20) NOT NULL UNIQUE,
    department_id INT NOT NULL,
    title NVARCHAR(50), -- Ví dụ: "TS.", "PGS.", "GS."
    degree NVARCHAR(50), -- Ví dụ: "Tiến sĩ", "Thạc sĩ"
    specialization NVARCHAR(MAX),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id)
);

-- 7. Bảng Đề tài đồ án (Project Topics)
CREATE TABLE project_topics (
    topic_id INT IDENTITY(1,1) PRIMARY KEY,
    topic_code NVARCHAR(20) NOT NULL UNIQUE,
    topic_name NVARCHAR(500) NOT NULL,
    description NVARCHAR(MAX),
    requirements NVARCHAR(MAX),
    supervisor_id INT NOT NULL,
    department_id INT NOT NULL,
    max_students INT DEFAULT 1,
    project_type NVARCHAR(50) NOT NULL,
    difficulty_level NVARCHAR(20) DEFAULT 'medium',
    is_available BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (supervisor_id) REFERENCES teachers(teacher_id),
    FOREIGN KEY (department_id) REFERENCES departments(department_id),
    CONSTRAINT chk_project_type CHECK (project_type IN ('graduation_thesis', 'course_project', 'research_project')),
    CONSTRAINT chk_difficulty_level CHECK (difficulty_level IN ('easy', 'medium', 'hard'))
);

-- 8. Bảng Đồ án (Projects) - Đồ án được gán cho sinh viên
CREATE TABLE projects (
    project_id INT IDENTITY(1,1) PRIMARY KEY,
    project_code NVARCHAR(30) NOT NULL UNIQUE,
    topic_id INT NOT NULL,
    project_name NVARCHAR(500) NOT NULL,
    supervisor_id INT NOT NULL,
    co_supervisor_id INT,
    start_date DATE NOT NULL,
    expected_end_date DATE NOT NULL,
    actual_end_date DATE,
    status NVARCHAR(30) DEFAULT 'assigned',
    final_score DECIMAL(4,2),
    notes NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (topic_id) REFERENCES project_topics(topic_id),
    FOREIGN KEY (supervisor_id) REFERENCES teachers(teacher_id),
    FOREIGN KEY (co_supervisor_id) REFERENCES teachers(teacher_id),
    CONSTRAINT chk_project_status CHECK (status IN ('assigned', 'in_progress', 'submitted', 'reviewing', 'completed', 'failed'))
);

-- 9. Bảng Sinh viên - Đồ án (Student Projects) - Quan hệ nhiều-nhiều
CREATE TABLE student_projects (
    student_project_id INT IDENTITY(1,1) PRIMARY KEY,
    student_id INT NOT NULL,
    project_id INT NOT NULL,
    role NVARCHAR(20) DEFAULT 'member',
    join_date DATE DEFAULT GETDATE(),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    CONSTRAINT chk_student_project_role CHECK (role IN ('leader', 'member')),
    CONSTRAINT uk_student_project UNIQUE (student_id, project_id)
);

-- 10. Bảng Giai đoạn đồ án (Project Phases)
CREATE TABLE project_phases (
    phase_id INT IDENTITY(1,1) PRIMARY KEY,
    project_id INT NOT NULL,
    phase_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    weight DECIMAL(5,2) DEFAULT 0.00, -- Trọng số của giai đoạn (%)
    status NVARCHAR(20) DEFAULT 'not_started',
    completion_percentage DECIMAL(5,2) DEFAULT 0.00,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    CONSTRAINT chk_phase_status CHECK (status IN ('not_started', 'in_progress', 'completed', 'overdue'))
);

-- 11. Bảng Nhiệm vụ (Tasks)
CREATE TABLE tasks (
    task_id INT IDENTITY(1,1) PRIMARY KEY,
    phase_id INT NOT NULL,
    task_name NVARCHAR(300) NOT NULL,
    description NVARCHAR(MAX),
    assigned_to INT, -- student_id
    priority NVARCHAR(20) DEFAULT 'medium',
    status NVARCHAR(20) DEFAULT 'not_started',
    start_date DATE,
    due_date DATE,
    completed_date DATE,
    estimated_hours DECIMAL(5,2),
    actual_hours DECIMAL(5,2),
    completion_percentage DECIMAL(5,2) DEFAULT 0.00,
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (phase_id) REFERENCES project_phases(phase_id),
    FOREIGN KEY (assigned_to) REFERENCES students(student_id),
    CONSTRAINT chk_task_priority CHECK (priority IN ('low', 'medium', 'high', 'urgent')),
    CONSTRAINT chk_task_status CHECK (status IN ('not_started', 'in_progress', 'completed', 'cancelled'))
);

-- 12. Bảng Báo cáo tiến độ (Progress Reports)
CREATE TABLE progress_reports (
    report_id INT IDENTITY(1,1) PRIMARY KEY,
    project_id INT NOT NULL,
    student_id INT NOT NULL,
    report_date DATE DEFAULT GETDATE(),
    week_number INT,
    work_completed NVARCHAR(MAX),
    work_planned NVARCHAR(MAX),
    issues_encountered NVARCHAR(MAX),
    supervisor_feedback NVARCHAR(MAX),
    supervisor_rating INT,
    submitted_at DATETIME2 DEFAULT GETDATE(),
    reviewed_at DATETIME2,
    reviewed_by INT, -- teacher_id
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (student_id) REFERENCES students(student_id),
    FOREIGN KEY (reviewed_by) REFERENCES teachers(teacher_id),
    CONSTRAINT chk_supervisor_rating CHECK (supervisor_rating >= 1 AND supervisor_rating <= 10)
);

-- 13. Bảng Tài liệu đồ án (Project Documents)
CREATE TABLE project_documents (
    document_id INT IDENTITY(1,1) PRIMARY KEY,
    project_id INT NOT NULL,
    document_name NVARCHAR(300) NOT NULL,
    document_type NVARCHAR(50) NOT NULL, -- 'proposal', 'report', 'presentation', 'source_code', 'other'
    file_path NVARCHAR(500) NOT NULL,
    file_size BIGINT,
    uploaded_by INT NOT NULL, -- user_id
    version NVARCHAR(10) DEFAULT '1.0',
    is_final BIT DEFAULT 0,
    description NVARCHAR(MAX),
    uploaded_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (uploaded_by) REFERENCES users(user_id)
);

-- 14. Bảng Hội đồng đánh giá (Evaluation Committees)
CREATE TABLE evaluation_committees (
    committee_id INT IDENTITY(1,1) PRIMARY KEY,
    committee_name NVARCHAR(200) NOT NULL,
    description NVARCHAR(MAX),
    created_date DATE DEFAULT GETDATE(),
    is_active BIT DEFAULT 1,
    created_at DATETIME2 DEFAULT GETDATE()
);

-- 15. Bảng Thành viên hội đồng (Committee Members)
CREATE TABLE committee_members (
    member_id INT IDENTITY(1,1) PRIMARY KEY,
    committee_id INT NOT NULL,
    teacher_id INT NOT NULL,
    role NVARCHAR(30) NOT NULL,
    joined_date DATE DEFAULT GETDATE(),
    is_active BIT DEFAULT 1,
    FOREIGN KEY (committee_id) REFERENCES evaluation_committees(committee_id),
    FOREIGN KEY (teacher_id) REFERENCES teachers(teacher_id),
    CONSTRAINT chk_committee_role CHECK (role IN ('chairman', 'member', 'secretary')),
    CONSTRAINT uk_committee_member UNIQUE (committee_id, teacher_id)
);

-- 16. Bảng Đánh giá đồ án (Project Evaluations)
CREATE TABLE project_evaluations (
    evaluation_id INT IDENTITY(1,1) PRIMARY KEY,
    project_id INT NOT NULL,
    committee_id INT NOT NULL,
    evaluation_date DATE DEFAULT GETDATE(),
    content_score DECIMAL(4,2), -- Điểm nội dung
    presentation_score DECIMAL(4,2), -- Điểm thuyết trình
    defense_score DECIMAL(4,2), -- Điểm bảo vệ
    total_score DECIMAL(4,2), -- Tổng điểm
    grade NVARCHAR(5), -- A, B+, B, C+, C, D+, D, F
    comments NVARCHAR(MAX),
    status NVARCHAR(20) DEFAULT 'scheduled',
    created_at DATETIME2 DEFAULT GETDATE(),
    updated_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (project_id) REFERENCES projects(project_id),
    FOREIGN KEY (committee_id) REFERENCES evaluation_committees(committee_id),
    CONSTRAINT chk_evaluation_status CHECK (status IN ('scheduled', 'completed', 'cancelled'))
);

-- 17. Bảng Thông báo (Notifications)
CREATE TABLE notifications (
    notification_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT NOT NULL,
    title NVARCHAR(200) NOT NULL,
    content NVARCHAR(MAX),
    type NVARCHAR(30) NOT NULL, -- 'deadline', 'assignment', 'evaluation', 'general'
    is_read BIT DEFAULT 0,
    related_project_id INT,
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (related_project_id) REFERENCES projects(project_id)
);

-- 18. Bảng Nhật ký hệ thống (System Logs)
CREATE TABLE system_logs (
    log_id INT IDENTITY(1,1) PRIMARY KEY,
    user_id INT,
    action NVARCHAR(100) NOT NULL,
    table_name NVARCHAR(50),
    record_id INT,
    old_values NVARCHAR(MAX) CONSTRAINT chk_old_values CHECK (ISJSON(old_values) = 1),
    new_values NVARCHAR(MAX) CONSTRAINT chk_new_values CHECK (ISJSON(new_values) = 1),
    ip_address NVARCHAR(45),
    user_agent NVARCHAR(MAX),
    created_at DATETIME2 DEFAULT GETDATE(),
    FOREIGN KEY (user_id) REFERENCES users(user_id)
);

-- Tạo các index để tối ưu hiệu suất
CREATE NONCLUSTERED INDEX idx_students_class_id ON students(class_id);
CREATE NONCLUSTERED INDEX idx_students_student_code ON students(student_code);
CREATE NONCLUSTERED INDEX idx_teachers_department_id ON teachers(department_id);
CREATE NONCLUSTERED INDEX idx_projects_supervisor_id ON projects(supervisor_id);
CREATE NONCLUSTERED INDEX idx_projects_status ON projects(status);
CREATE NONCLUSTERED INDEX idx_student_projects_student_id ON student_projects(student_id);
CREATE NONCLUSTERED INDEX idx_student_projects_project_id ON student_projects(project_id);
CREATE NONCLUSTERED INDEX idx_tasks_assigned_to ON tasks(assigned_to);
CREATE NONCLUSTERED INDEX idx_tasks_status ON tasks(status);
CREATE NONCLUSTERED INDEX idx_progress_reports_project_id ON progress_reports(project_id);
CREATE NONCLUSTERED INDEX idx_progress_reports_student_id ON progress_reports(student_id);
CREATE NONCLUSTERED INDEX idx_project_documents_project_id ON project_documents(project_id);
CREATE NONCLUSTERED INDEX idx_notifications_user_id ON notifications(user_id);
CREATE NONCLUSTERED INDEX idx_notifications_is_read ON notifications(is_read);

-- Tạo stored procedure để tự động cập nhật updated_at
CREATE PROCEDURE update_updated_at_column
AS
BEGIN
    SET NOCOUNT ON;
    -- This procedure will be used in triggers
END;

-- Tạo trigger cho các bảng cần cập nhật updated_at
CREATE TRIGGER update_departments_updated_at ON departments
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE departments
    SET updated_at = GETDATE()
    FROM departments d
    INNER JOIN inserted i ON d.department_id = i.department_id;
END;

CREATE TRIGGER update_majors_updated_at ON majors
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE majors
    SET updated_at = GETDATE()
    FROM majors m
    INNER JOIN inserted i ON m.major_id = i.major_id;
END;

CREATE TRIGGER update_classes_updated_at ON classes
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE classes
    SET updated_at = GETDATE()
    FROM classes c
    INNER JOIN inserted i ON c.class_id = i.class_id;
END;

CREATE TRIGGER update_users_updated_at ON users
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE users
    SET updated_at = GETDATE()
    FROM users u
    INNER JOIN inserted i ON u.user_id = i.user_id;
END;

CREATE TRIGGER update_students_updated_at ON students
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE students
    SET updated_at = GETDATE()
    FROM students s
    INNER JOIN inserted i ON s.student_id = i.student_id;
END;

CREATE TRIGGER update_teachers_updated_at ON teachers
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE teachers
    SET updated_at = GETDATE()
    FROM teachers t
    INNER JOIN inserted i ON t.teacher_id = i.teacher_id;
END;

CREATE TRIGGER update_project_topics_updated_at ON project_topics
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE project_topics
    SET updated_at = GETDATE()
    FROM project_topics pt
    INNER JOIN inserted i ON pt.topic_id = i.topic_id;
END;

CREATE TRIGGER update_projects_updated_at ON projects
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE projects
    SET updated_at = GETDATE()
    FROM projects p
    INNER JOIN inserted i ON p.project_id = i.project_id;
END;

CREATE TRIGGER update_project_phases_updated_at ON project_phases
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE project_phases
    SET updated_at = GETDATE()
    FROM project_phases pp
    INNER JOIN inserted i ON pp.phase_id = i.phase_id;
END;

CREATE TRIGGER update_tasks_updated_at ON tasks
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE tasks
    SET updated_at = GETDATE()
    FROM tasks t
    INNER JOIN inserted i ON t.task_id = i.task_id;
END;

CREATE TRIGGER update_project_evaluations_updated_at ON project_evaluations
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE project_evaluations
    SET updated_at = GETDATE()
    FROM project_evaluations pe
    INNER JOIN inserted i ON pe.evaluation_id = i.evaluation_id;
END;



