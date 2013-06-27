package ZAPP::PACK::Constant;

## 周期确认控制表工作状态
sub PMISSION_STARTABLE          () { 1 }  # 可开始
sub PMISSION_SUCCESS_EXPORT     () { 2 }  # 导出成功
sub PMISSION_RUNNING            () { 3 }  # 确认中
sub PMISSION_SUCCESS            () { 4 }  # 确认成功
sub PMISSION_NO_PERIOD          () { -1 } # 未达确认周期
sub PMISSION_FAIL_EXPORT        () { -2 } # 导出失败
sub PMISSION_FAIL               () { -3 } # 确认失败

## 其他
sub PACK_YSPZ                   () { '0031' } # 周期确认原始凭证编号


sub import {
    my $pkg = caller(); 

    ## 周期确认控制表工作状态
    *{ $pkg . "::PMISSION_STARTABLE"        } = \&PMISSION_STARTABLE     ;  # 可开始
    *{ $pkg . "::PMISSION_SUCCESS_EXPORT"   } = \&PMISSION_SUCCESS_EXPORT;  # 导出成功
    *{ $pkg . "::PMISSION_RUNNING"          } = \&PMISSION_RUNNING       ;  # 确认中
    *{ $pkg . "::PMISSION_SUCCESS"          } = \&PMISSION_SUCCESS       ;  # 确认成功
    *{ $pkg . "::PMISSION_NO_PERIOD"        } = \&PMISSION_NO_PERIOD     ;  # 未达确认周期
    *{ $pkg . "::PMISSION_FAIL_EXPORT"      } = \&PMISSION_FAIL_EXPORT   ;  # 导出失败
    *{ $pkg . "::PMISSION_FAIL"             } = \&PMISSION_FAIL          ;  # 确认失败
    
    ## 其他
    *{ $pkg . "::PACK_YSPZ"                 } = \&PACK_YSPZ               ;  # 周期确认原始凭证编号

    return 1;
}


1;

__END__
