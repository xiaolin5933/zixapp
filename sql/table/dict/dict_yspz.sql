--
-- 原始凭证描述表
--
drop table dict_yspz;
create table dict_yspz (
    code      char(4)      not null primary key,
    name      varchar(128) not null,
    memo      varchar(512) not null,
    ts_c      timestamp    default current timestamp
) in tbs_dat index in tbs_idx;


--
-- 原始凭证类型信息
--
comment on table  dict_yspz           is '原始凭证类型信息';
comment on column dict_yspz.code      is '凭证编号';
comment on column dict_yspz.memo      is '凭证描述';


insert into dict_yspz(code, name, memo) values
('0000', '特种调账单', '特种调账单'),
('0001', '基金行业线-备付金内扣成本补充', '基金行业线-备付金内扣成本补充'),
('0002', '基金线-委托收款勾兑成功', '基金线-委托收款勾兑成功'),
('0003', '基金线-委托收款勾兑不成功（我有银无）', '基金线-委托收款勾兑不成功（我有银无）'),
('0004', '基金线-委托收款勾兑不成功（银有我无）', '基金线-委托收款勾兑不成功（银有我无）'),
('0005', '基金线-委托收款勾兑不成功（我有银无，追回，处理完成）', '基金线-委托收款勾兑不成功（我有银无，追回，处理完成）'),
('0006', '基金线-委托收款勾兑不成功（银有我无，补付客户备付金）', '基金线-委托收款勾兑不成功（银有我无，补付客户备付金）'),
('0007', '基金线-委托收款结算', '基金线-委托收款结算'),
('0008', '基金线-赎回款汇入成功', '基金线-赎回款汇入成功'),
('0009', '基金线-赎回款汇出成功', '基金线-赎回款汇出成功'),
('0010', '基金线资金对账成功', '基金线资金对账成功'),
('0011', '基金线资金对账银行多付（银行长款）', '基金线资金对账银行多付（银行长款）'),
('0012', '基金线资金对账银行少付（银行短款）', '基金线资金对账银行少付（银行短款）'),
('0013', '基金线-账户管理费', '基金线-账户管理费'),
('0014', '基金线-账户利息收入', '基金线-账户利息收入'),
('0015', '基金线-备付金账户间资金划拨', '基金线-备付金账户间资金划拨'),
('0016', '直联POS代清算收款勾兑成功', '直联POS代清算收款勾兑成功'),
('0017', '直联POS代清算收款反向交易勾兑成功', '直联POS代清算收款反向交易勾兑成功');

