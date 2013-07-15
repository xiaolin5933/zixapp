package ZAPP::PACK::Constant;

## 周期确认控制表工作状态
sub PMISSION_STARTABLE          () { 1 }  # 可生成 
sub PMISSION_RUNNING_EXPORT     () { 2 }  # 生成中
sub PMISSION_SUCCESS_EXPORT     () { 3 }  # 生成成功
sub PMISSION_NONE               () { -1 } # 无
sub PMISSION_FAIL_EXPORT        () { -2 } # 生成失败

## 其他
sub PACK_YSPZ                   () { '0031' } # 周期确认原始凭证编号


sub import {
    my $pkg = caller(); 

    ## 周期确认控制表工作状态
    *{ $pkg . "::PMISSION_STARTABLE"        } = \&PMISSION_STARTABLE     ;  # 可生成
    *{ $pkg . "::PMISSION_RUNNING_EXPORT"   } = \&PMISSION_RUNNING_EXPORT;  # 生成中
    *{ $pkg . "::PMISSION_SUCCESS_EXPORT"   } = \&PMISSION_SUCCESS_EXPORT;  # 生成成功
    *{ $pkg . "::PMISSION_NONE"             } = \&PMISSION_NONE          ;  # 无
    *{ $pkg . "::PMISSION_FAIL_EXPORT"      } = \&PMISSION_FAIL_EXPORT   ;  # 生成失败
    
    ## 其他
    *{ $pkg . "::PACK_YSPZ"                 } = \&PACK_YSPZ               ;  # 周期确认原始凭证编号

    return 1;
}


1;

__END__
