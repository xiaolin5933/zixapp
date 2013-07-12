package ZAPP::YSPZ::Constant;

# 常量
# 凭证导入流水下载协议
sub LOAD_PROTO_FTP      () { '1' } # Ftp
sub LOAD_PROTO_FILE     () { '2' } # File
sub LOAD_PROTO_HTTP     () { '3' } # HTTP

# 状态
sub MISSION_STARTABLE   () { 1 } # 可开始
sub MISSION_DOWNING     () { 2 } # 下载中
sub MISSION_ASSIGNABLE  () { 3 } # 可分配
sub MISSION_ASSIGNING   () { 4 } # 分配中
sub MISSION_RUNNABLE    () { 5 } # 可运行
sub MISSION_RUNNING     () { 6 } # 运行中
sub MISSION_SUCCESS     () { 7 } # 运行成功
sub MISSION_FAIL_DOWN   () { -1 } # 下载失败
sub MISSION_FAIL_ASSIGN () { -2 } # 分配失败
sub MISSION_FAIL_RUN    () { -3 } # 运行失败
sub JOB_RUNNABLE        () { 1 } # 可运行
sub JOB_RUNNING         () { 2 } # 运行中
sub JOB_SUCCESS         () { 3 } # 运行成功
sub JOB_FAIL            () { -1 } # 运行失败


sub import {

    my $pkg = caller();
    
    *{ $pkg . "::LOAD_PROTO_FTP"      } = \&LOAD_PROTO_FTP     ;  # Ftp     
    *{ $pkg . "::LOAD_PROTO_FILE"     } = \&LOAD_PROTO_FILE    ;  # File
    *{ $pkg . "::LOAD_PROTO_HTTP"     } = \&LOAD_PROTO_HTTP    ;  # Http

    *{ $pkg . "::MISSION_STARTABLE"   } = \&MISSION_STARTABLE  ;  # 可开始
    *{ $pkg . "::MISSION_DOWNING"     } = \&MISSION_DOWNING    ;  # 下载中
    *{ $pkg . "::MISSION_ASSIGNABLE"  } = \&MISSION_ASSIGNABLE ;  # 可分配
    *{ $pkg . "::MISSION_ASSIGNING"   } = \&MISSION_ASSIGNING  ;  # 分配中
    *{ $pkg . "::MISSION_RUNNABLE"    } = \&MISSION_RUNNABLE   ;  # 可运行
    *{ $pkg . "::MISSION_RUNNING"     } = \&MISSION_RUNNING    ;  # 运行中
    *{ $pkg . "::MISSION_SUCCESS"     } = \&MISSION_SUCCESS    ;  # 运行成功
    *{ $pkg . "::MISSION_FAIL_DOWN"   } = \&MISSION_FAIL_DOWN  ;  # 下载失败
    *{ $pkg . "::MISSION_FAIL_ASSIGN" } = \&MISSION_FAIL_ASSIGN;  # 分配失败
    *{ $pkg . "::MISSION_FAIL_RUN"    } = \&MISSION_FAIL_RUN   ;  # 运行失败
    *{ $pkg . "::JOB_RUNNABLE"        } = \&JOB_RUNNABLE       ;  # 可运行
    *{ $pkg . "::JOB_RUNNING"         } = \&JOB_RUNNING        ;  # 运行中
    *{ $pkg . "::JOB_SUCCESS"         } = \&JOB_SUCCESS        ;  # 运行成功
    *{ $pkg . "::JOB_FAIL"            } = \&JOB_FAIL           ;  # 运行失败
    return 1;
}

1;

__END__





