package ZAPP::DT;
use strict;
use warnings;
use DateTime;
use DateTime::Duration;
use Carp;
use constant {
    DEBUG => $ENV{ZAPP_DT_DEBUG} || 0,
};

BEGIN {
   require Data::Dump if DEBUG;
}

#
# 参数: $cfg
#
# 对象结构
# {
#    2012 => { days => 365, holiday => [] },
#    2013 => { days => 365, holiday => [] },
#    2014 => { days => 365, holiday => [] }
# }
#
sub new {
    my ($class, $cfg) = @_;
    my $self = bless {}, $class;
    $self->_init($cfg->{dbh});
    return $self;
}

#
# 初始化对象结构
#
sub _init {
    my ($self, $dbh) = @_;
    return unless $dbh;
   
    my $sel = $dbh->prepare(<<EOF);
select year, days, holiday from dict_holi where year > ? and year < ? order by year asc
EOF
  
    # 加载前年，去年，今年，明年，一共4年数据
    my $year = DateTime->now(time_zone => 'local')->year();
    $sel->execute($year - 3, $year + 2); 
    while(my $row = $sel->fetchrow_hashref()) {
        Data::Dump->dump($row) if DEBUG;
        warn "get holiday for year[$row->{year}] [$row->{holiday}]" if DEBUG;
        my @bitmap;
        for (split ',', $row->{holiday}) {
            $bitmap[$_] = 1;
        }
        $self->{$row->{year}} = {
            days    => $row->{days},
            holiday => \@bitmap,
        };
    }
    $sel->finish();
   
    return $self;
}

#
# 下n个工作日
# 参数:
#     $date :  日期
#     $n    :  下几个工作, 小于0为前几个工作日
#
sub next_n_wday {
    my ($self, $date, $n) = @_;
    return $date if $n == 0;
    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    return $self->next_n_wday_dt(
        DateTime->new(time_zone => 'local', year => $1, month => $2, day => $3), $n)->ymd('-');
}

#
#  下n个工作日dt版本
#  $self->next_n_wday_dt($dt, $n);
#
sub next_n_wday_dt {
    my ($self, $dt, $n) = @_;
    return $dt if $n == 0 ;

    my $day  = $dt->day_of_year();   # 当年的第几天
    my $year = $dt->year();          # 哪一年

    if ($n > 0 ) {
        my $dur = 0;
        while ($n > 0 ) {
           ++$day;
           if ($day > $self->{$year}->{days}) {
               ++$year;
               $day = DateTime->new(time_zone => 'local', year => $year, month => 1, day => 1)->day_of_year();
               unless ($self->{$year}) {
                   confess "ERROR: 无法计算, 只有[" . join(',', sort keys %{$self}) . "], 需要[$year]";
               }
           }
           # 如果是节假日
           if ($self->{$year}->{holiday}[$day]) {
               ++$dur;
               next;
           }
           $n--;
           ++$dur; 
        }
        return $dt->add(DateTime::Duration->new(days => $dur));
    }
    else {
        my $dur = 0;
        while($n != 0) {
            --$day;
            if ( $day < 0 ) {
                --$year;
                $day = DateTime->new(time_zone => 'local', year => $year, month => 12, day => 31)->day_of_year();
                unless($self->{$year}) {
                    confess "ERROR: 无法计算, 只有[" . join(',', sort keys %{$self}) . "], 需要[$year]";
                }
            }
            if ( $self->{$year}->{holiday}[$day]) {
                 ++$dur;
                 next; 
            }
            ++$n;
            ++$dur;
        }
        return $dt->subtract(DateTime::Duration->new(days => $dur));
    }
}

#
#  下n个自然日
#  $self->next_n_day($date, $n);
#
sub next_n_day {
    my ($self, $date, $n) = @_;
    return $date if $n == 0;

    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    my $dt = DateTime->new( time_zone => 'local', year => $1, month => $2, day => $3);

    return $n > 0 ? $dt->add(DateTime::Duration->new( days => $n))->ymd('-') :
                    $dt->subtract(DateTime::Duration->new( days => -$n))->ymd('-');
}

#
#  下n个自然日dt版本
#  $self->next_n_day($dt, $n);
#
sub next_n_day_dt {
    my ($self, $dt, $n) = @_;
    return $dt if $n == 0;
  
    return $n > 0 ? $dt->add(DateTime::Duration->new( days => $n)) :
                    $dt->subtract(DateTime::Duration->new( days => -$n));
}

  

#
# 是否为工作日
#
sub is_wday {
    my ($self, $date ) = @_;
    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    my $year = $1;
    return $self->is_wday_dt(DateTime->new( time_zone => 'local', year => $1, month => $2, day => $3));
}

#
# 是否为工作dt版
#
sub is_wday_dt {
    my ($self, $dt) = @_;
    my $year = $dt->year();
    my $day = $dt->day_of_year();
    unless($self->{$year}) {
        confess "ERROR: 无法计算, 只有[" . join(',', sort keys %{$self}) . "], 需要[$year]";
    }
    return $self unless $self->{$year}->{holiday}[$day];
    return; 
}

#
# 周最后一天
#
sub week_last {
    my ($self, $date) = @_;
    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    my $dt = DateTime->new( time_zone => 'local', year => $1, month => $2, day => $3);
    $dt->add(DateTime::Duration->new( days => 7 - $dt->day_of_week));
    return $dt->ymd('-');
}

#
# 周最后一天dt版本
#
sub week_last_dt {
    my ($self, $dt) = @_;
    return $dt->add(DateTime::Duration->new( days => 7 - $dt->day_of_week));
}


#
# 月最后一天
#
sub month_last {
    my ($self, $date) = @_;
    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    return DateTime->last_day_of_month(time_zone => 'local', year => $1, month => $2)->ymd('-');
}

#
# 月最后一天dt版
#
sub month_last_dt {
    my ($self, $dt) = @_;
    return DateTime->last_day_of_month(time_zone => 'local', year => $1, month => $dt->month());
}

#
# 季度最后一天
#
sub quarter_last {
    my ($self, $date) = @_;
    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    my $year = $1;
    my $dt = DateTime->new( time_zone => 'local', year => $year, month => $2, day => $3);
    my $month =  $dt->quarter * 3;
    return DateTime->last_day_of_month( time_zone => 'local', year => $year, month => $month)->ymd('-');
}

#
# 季度最后一天dt版
#
sub quarter_last_dt {
    my ($self, $dt) = @_;
    return DateTime->last_day_of_month( time_zone => 'local', year => $dt->year, month => $dt->quarter * 3);
}
 
 

#
# 半年最后一起
#
sub semi_year_last {
    my ($self, $date) = @_;
    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    return $2 > 6 ? "$1-12-31" : "$1-06-30";
}

#
# 半年最后一天dt版
#
sub semi_year_last_dt {
    my ($self, $dt) = @_;
    return $dt->month() > 6 ? $dt->set_month(12)->set_day(31) : $dt->set_month(6)->set_day(30);
}

#
# 年最后一天
#
sub year_last {
    my ($self, $date) = @_;
    $date =~ /^(\d{4})-/;
    return "$1-12-31";
}

#
# 年最后一天dt版
#
sub year_last_dt {
    my ($self, $dt) = @_;
    return $dt->set_month(12)->set_day(31);
}

1;

__END__

