package ZAPP::DT;
use strict;
use warnings;
use DateTime;
use DateTime::Duration;
use Carp;
use constant {
    DEBUG      => $ENV{ZAPP_DT_DEBUG} || 0,
};

BEGIN {
   require Data::Dump if DEBUG;
}

#
# 参数:
# (
#    dbh => $dbh
# )
#
# 对象结构
# {
#    2012 => { days => 365, holiday => [] },
#    2013 => { days => 365, holiday => [] },
#    2014 => { days => 365, holiday => [] }
# }
#
sub new {
    my $self = bless {}, shift;
    $self->_init({@_});
}

#
# 初始化对象结构
#
sub _init {
    my ($self, $args) = @_;
    my $dbh = $args->{dbh};
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
    $dbh->rollback();
    $dbh->disconnect();
   
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
    my $year = $1;
    my $dt = DateTime->new(time_zone => 'local', year => $year, month => $2, day => $3);
    my $day = $dt->day_of_year();
 
    # 下几个工作日
    if ( $n > 0 ) {
        my $dur = 0;
        while ($n > 0 ) {
           ++$day;
           if ($day > $self->{$year}->{days}) {
               ++$year;
               unless ($self->{$year}) {
                   confess "ERROR: 无法计算, 只有[" . join(',', sort keys @{$self}) . "], 需要[$year]";
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
        return $dt->add(DateTime::Duration->new(days => $dur))->ymd('-');
    }
    # 前几个工作日
    else {
        my $dur = 0;
        while($n != 0 ) {
            --$day;
            if ($day < 0 ) {
                --$year;
                $day = DateTime->new(time_zone => 'local', year => $year, month => 12, day => 31)->day_of_year();
                unless($self->{$year}) {
                    confess "ERROR: 无法计算, 只有[" . join(',', sort keys %{$self}) . "], 需要[$year]";
                }
            }
            if ($self->{$year}->{holiday}[$day]) {
                ++$dur;
                next;
            }
            ++$n;
            ++$dur;
        } 
        return $dt->subtract(DateTime::Duration->new(days => $dur) )->ymd('-');
    }
}
  

#
# 是否为工作日
#
sub is_wday {

    my ($self, $date) = @_;
    $date =~ /(\d{4})(\d{2})(\d{2})/;
    my $year = $1;
    my $dt = DateTime->new( time_zone => 'local', year => $1, month => $2, day => $3);
    my $day = $dt->day_of_year();
    unless($self->{$year}) {
        confess "ERROR: 无法计算, 只有[" . join(',', sort keys @{$self}) . "], 需要[$year]";
    }
    return 1 unless $self->{$year}->{holiday}[$day];
}

#
# 周最后一天
#
sub week_last {
    my ($self, $date) = @_;
    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    my $year = $1;
    my $dt = DateTime->new( time_zone => 'local', year => $1, month => $2, day => $3);
    my $day = $dt->day_of_week();
    $dt->add(DateTime::Duration->new( days => 7 - $day));
    return $dt->ymd('-');
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
# 半年最后一起
#
sub semi_year_last {
    my ($self, $date) = @_;
    $date =~ /(\d{4})-(\d{2})-(\d{2})/;
    if ($2 > 6) {
        return "$1-12-31"; 
    }
    else {
        return "$1-06-30";
    }
}

#
# 年最后一天
#
sub year_last {
    my ($self, $date) = @_;
    $date =~ /^(\d{4})-/;
    return "$1-12-31";
}

1;

__END__

