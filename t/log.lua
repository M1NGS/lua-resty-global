local ffi = ffi
local C = ffi.C
local stderr = io.stderr
local stdout = io.stdout
local sprintf = string.format

ffi.cdef [[
    void syslog(int priority, const char *format, ...);
    void __syslog(int priority, const char *format, ...);
    void openlog(const char *ident, int option, int facility);
    void closelog();
    int getppid(void);
]]

--[[
#define LOG_EMERG       0       /* system is unusable */
#define LOG_ALERT       1       /* action must be taken immediately */
#define LOG_CRIT        2       /* critical conditions */
#define LOG_ERR         3       /* error conditions */
#define LOG_WARNING     4       /* warning conditions */
#define LOG_NOTICE      5       /* normal but significant condition */
#define LOG_INFO        6       /* informational */
#define LOG_DEBUG       7       /* debug-level messages */
/* facility codes */
#define LOG_KERN        (0<<3)  /* kernel messages */
#define LOG_USER        (1<<3)  /* random user-level messages */
#define LOG_MAIL        (2<<3)  /* mail system */
#define LOG_DAEMON      (3<<3)  /* system daemons */
#define LOG_AUTH        (4<<3)  /* security/authorization messages */
#define LOG_SYSLOG      (5<<3)  /* messages generated internally by syslogd */
#define LOG_LPR         (6<<3)  /* line printer subsystem */
#define LOG_NEWS        (7<<3)  /* network news subsystem */
#define LOG_UUCP        (8<<3)  /* UUCP subsystem */
#define LOG_CRON        (9<<3)  /* clock daemon */
#define LOG_AUTHPRIV    (10<<3) /* security/authorization messages (private) */
#define LOG_FTP         (11<<3) /* ftp daemon */
        /* other codes through 15 reserved for system use */
#define LOG_LOCAL0      (16<<3) /* reserved for local use */
#define LOG_LOCAL1      (17<<3) /* reserved for local use */
#define LOG_LOCAL2      (18<<3) /* reserved for local use */
#define LOG_LOCAL3      (19<<3) /* reserved for local use */
#define LOG_LOCAL4      (20<<3) /* reserved for local use */
#define LOG_LOCAL5      (21<<3) /* reserved for local use */
#define LOG_LOCAL6      (22<<3) /* reserved for local use */
#define LOG_LOCAL7      (23<<3) /* reserved for local use */
#define LOG_PID         0x01    /* log the pid with each message */
#define LOG_CONS        0x02    /* log on the console if errors in sending */
#define LOG_ODELAY      0x04    /* delay open until first syslog() (default) */
#define LOG_NDELAY      0x08    /* don't delay open */
#define LOG_NOWAIT      0x10    /* don't wait for console forks: DEPRECATED */
#define LOG_PERROR      0x20    /* log to stderr as well */
]]

-- for buildin syslog
local syslog
if pcall(function()
    type(C.syslog)
end) then
    syslog = C.syslog
else
    syslog = C.__syslog
end

local openlog = C.openlog
local closelog = C.closelog
local _P = {}

---------syslog
function _P.syserr(str, ...)
    syslog(3, str, ...)
end
function _P.syswar(str, ...)
    syslog(4, str, ...)
end
function _P.sysinf(str, ...)
    syslog(5, str, ...)
end

function _P.sysopen(name)
    openlog(name, 1, 8)
end

function _P.sysclose()
    closelog()
end
----------stderr
--[[
\27[ 1;2;37;4;5
1 => 粗体
2 => 50%亮度
3x => 前景色
    0	黑色
    1	红色
    2	绿色
    3	黄色
    4	蓝色
    5	紫色
    6	青色
    7	白色
4 => 下划线
4x => 背景色
    0	黑色
    1	红色
    2	绿色
    3	黄色
    4	蓝色
    5	紫色
    6	青色
    7	白色
5 => 闪烁
]\27[0m
]]

function _P.stderr(str, ...)
    stderr:write("\27[30;41m", sprintf(str, ...) .. "\27[0m\n")
end

function _P.stdwar(str, ...)
    stdout:write("\27[30;43m", sprintf(str, ...) .. "\27[0m\n")
end

function _P.stdinf(str, ...)
    stdout:write("\27[30;42m", sprintf(str, ...) .. "\27[0m\n")
end

return _P
