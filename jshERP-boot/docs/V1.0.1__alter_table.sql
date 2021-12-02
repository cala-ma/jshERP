-- ----------------------------
-- 添加序列号表
-- ----------------------------
DROP TABLE IF EXISTS `jsh_serial_number`;
CREATE TABLE `jsh_serial_number` (
                                     `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                     `material_Id` bigint(20) DEFAULT NULL COMMENT '产品表id',
                                     `serial_Number` varchar(64) DEFAULT NULL COMMENT '序列号',
                                     `is_Sell` bit(1) DEFAULT 0 COMMENT '是否卖出，0未卖出，1卖出',
                                     `remark` varchar(1024) DEFAULT NULL COMMENT '备注',
                                     `delete_Flag` bit(1) DEFAULT 0 COMMENT '删除标记，0未删除，1删除',
                                     `create_Time` datetime DEFAULT NULL COMMENT '创建时间',
                                     `creator` bigint(20) DEFAULT NULL COMMENT '创建人',
                                     `update_Time` datetime DEFAULT NULL COMMENT '更新时间',
                                     `updater` bigint(20) DEFAULT NULL COMMENT '更新人',
                                     PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='序列号表';

-- ----------------------------
-- 产品表新增字段是否启用序列号
-- ----------------------------
alter table jsh_material add enableSerialNumber bit(1) DEFAULT 0 COMMENT '是否开启序列号，0否，1是';
-- ----------------------------
-- 时间：2019年1月24日
-- version：1.0.1
-- 此次更新添加序列号菜单
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
-- ----------------------------
-- 添加序列号菜单
-- ----------------------------
delete from `jsh_functions` where Name='序列号';
INSERT INTO `jsh_functions`(`Number`, `Name`, `PNumber`, `URL`, `State`, `Sort`, `Enabled`, `Type`, `PushBtn`) VALUES ('010104', '序列号', '0101', '../manage/serialNumber.html', b'0', '0246', b'1', '电脑版', '');
-- ----------------------------
-- 删除单据主表供应商id字段对应外键约束
-- ----------------------------
ALTER TABLE jsh_depot_head DROP FOREIGN KEY jsh_depot_head_ibfk_3;
-- ----------------------------
-- 序列号表添加单据主表id字段，用于跟踪序列号流向
-- ----------------------------
alter table jsh_serial_number add depothead_Id bigint(20) DEFAULT null COMMENT '单据主表id，用于跟踪序列号流向';
-- ----------------------------
-- 修改商品表enableSerialNumber字段类型为varchar(1)
-- ----------------------------
alter table jsh_material change enableSerialNumber enableSerialNumber varchar(1) DEFAULT '0' COMMENT '是否开启序列号，0否，1是';
-- ----------------------------
-- 修改序列号表is_Sell字段类型为varchar(1)
-- 修改序列号表delete_Flag字段类型为varchar(1)
-- ----------------------------
alter table jsh_serial_number change is_Sell is_Sell varchar(1) DEFAULT '0' COMMENT '是否卖出，0未卖出，1卖出';
alter table jsh_serial_number change delete_Flag delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- ----------------------------
-- 删除单据子表单据主表id字段对应外键约束
-- ----------------------------
ALTER TABLE jsh_depot_item DROP FOREIGN KEY jsh_depot_item_ibfk_1;
-- ----------------------------
-- 时间：2019年2月1日
-- version：1.0.2
-- 此次更新添加sequence表，用于获取一个唯一的数值
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
-- ----------------------------
-- 添加表tbl_sequence
-- ----------------------------
DROP TABLE IF EXISTS `tbl_sequence`;
CREATE TABLE tbl_sequence (
                              seq_name VARCHAR(50) NOT NULL COMMENT '序列名称',
                              min_value bigint(20) NOT NULL COMMENT '最小值',
                              max_value bigint(20) NOT NULL COMMENT '最大值',
                              current_val bigint(20) NOT NULL COMMENT '当前值',
                              increment_val INT DEFAULT '1' NOT NULL COMMENT '增长步数',
                              remark VARCHAR(500) DEFAULT null  COMMENT '备注',
                              PRIMARY KEY (seq_name)
)ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='sequence表';

-- ----------------------------
-- 添加表单据编号sequence
-- 插入数据前判断，防止数据重复插入
-- ----------------------------
insert into tbl_sequence (seq_name, min_value, max_value, current_val, increment_val,remark)
select 'depot_number_seq', 1, 999999999999999999, 1, 1,'单据编号sequence' from dual where not exists
    (select * from tbl_sequence where  seq_name='depot_number_seq');
-- ----------------------------
-- 创建function _nextval() 用于获取当前序列号
-- ----------------------------
DROP FUNCTION IF EXISTS `_nextval`;
DELIMITER ;;
CREATE FUNCTION `_nextval`(name varchar(50)) RETURNS mediumtext CHARSET utf8
begin
declare _cur bigint;
declare _maxvalue bigint;  -- 接收最大值
declare _increment int; -- 接收增长步数
set _increment = (select increment_val from tbl_sequence where seq_name = name);
set _maxvalue = (select max_value from tbl_sequence where seq_name = name);
set _cur = (select current_val from tbl_sequence where seq_name = name for update);
update tbl_sequence                      -- 更新当前值
set current_val = _cur + increment_val
where seq_name = name ;
if(_cur + _increment >= _maxvalue) then  -- 判断是都达到最大值
update tbl_sequence
set current_val = minvalue
where seq_name = name ;
end if;
return _cur;
end
;;
DELIMITER ;

-- ----------------------------
-- 时间：2019年2月18日
-- version：1.0.3
-- 此次更新修改产品类型表jsh_materialcategory，添加一些字段
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
-- ----------------------------
-- 产品类型表添加字段sort，显示顺序
-- ----------------------------
alter table jsh_materialcategory add sort varchar(10) DEFAULT null COMMENT '显示顺序';
-- ----------------------------
-- 产品类型表添加字段status，状态，0系统默认，1启用，2删除
-- ----------------------------
alter table jsh_materialcategory add status varchar(1) DEFAULT '0' COMMENT '状态，0系统默认，1启用，2删除';
-- ----------------------------
-- 产品类型表添加字段serial_no，编号
-- ----------------------------
alter table jsh_materialcategory add serial_no varchar(100) DEFAULT null COMMENT '编号';
-- ----------------------------
-- 产品类型表添加字段remark，备注
-- ----------------------------
alter table jsh_materialcategory add remark varchar(1024) DEFAULT null COMMENT '备注';
-- ----------------------------
-- 产品类型表添加字段create_time，创建时间
-- ----------------------------
alter table jsh_materialcategory add create_time datetime DEFAULT null COMMENT '创建时间';
-- ----------------------------
-- 产品类型表添加字段creator，创建人
-- ----------------------------
alter table jsh_materialcategory add creator bigint(20) DEFAULT null COMMENT '创建人';
-- ----------------------------
-- 产品类型表添加字段update_time，更新时间
-- ----------------------------
alter table jsh_materialcategory add update_time datetime DEFAULT null COMMENT '更新时间';
-- ----------------------------
-- 产品类型表添加字段updater，更新人
-- ----------------------------
alter table jsh_materialcategory add updater bigint(20) DEFAULT null COMMENT '更新人';

-- ----------------------------
-- 去掉jsh_materialcategory外键
-- ----------------------------
ALTER TABLE jsh_materialcategory DROP FOREIGN KEY FK3EE7F725237A77D8;

-- ----------------------------
-- 修改根目录父节点id为-1
-- 设置根目录编号为1
-- ----------------------------
update jsh_materialcategory set ParentId='-1' where id='1';

-- ----------------------------
-- 删除礼品卡管理、礼品充值、礼品销售、礼品卡统计的功能数据
-- ----------------------------
delete from jsh_functions where id in (213,214,215,216);

-- ----------------------------
-- 新增采购订单、销售订单的功能数据
-- 主键自增长，直接指定主键插入数据的方式可能会和本地数据冲突
-- 插入数据前判断，防止数据重复插入
-- ----------------------------
insert into `jsh_functions`(`Number`, `Name`, `PNumber`, `URL`, `State`, `Sort`, `Enabled`, `Type`, `PushBtn`)
select '050202', '采购订单', '0502', '../materials/purchase_orders_list.html', b'0', '0335',b'1', '电脑版', '' from dual where not exists
    (select * from jsh_functions where  Number='050202' and PNumber='0502');
insert into `jsh_functions`(`Number`, `Name`, `PNumber`, `URL`, `State`, `Sort`, `Enabled`, `Type`, `PushBtn`)
select '060301', '销售订单', '0603', '../materials/sale_orders_list.html', b'0', '0392', b'1', '电脑版', '' from dual where not exists
    (select * from jsh_functions where  Number='060301' and PNumber='0603');

-- ----------------------------
-- 改管理员的功能权限
-- ----------------------------
update jsh_userbusiness SET Type = 'RoleFunctions', KeyId = '4',
                            Value = '[13][12][16][14][15][234][236][22][23][220][240][25][217][218][26][194][195][31][59][207][208][209][226][227][228][229][235][237][210][211][242][33][199][243][41][200][201][202][40][232][233][197][203][204][205][206][212]'
where Id = 5;

-- ----------------------------
-- 时间：2019年2月25日
-- version：1.0.4
-- 此次更新仓库添加负责人信息，负责人信息从用户表获取
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
-- ----------------------------
-- 仓库表添加字段principal，负责人
-- ----------------------------
alter table jsh_depot add principal bigint(20) DEFAULT null COMMENT '负责人';

-- ----------------------------
-- 时间：2019年3月6日
-- version：1.0.5
-- 此次更新
-- 1、添加机构表
-- 2、添加机构用户关系表
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
-- ----------------------------
-- 添加机构表
-- ----------------------------
DROP TABLE IF EXISTS `jsh_organization`;
CREATE TABLE `jsh_organization` (
                                    `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                    `org_no` varchar(20) DEFAULT NULL COMMENT '机构编号',
                                    `org_full_name` varchar(500) DEFAULT NULL COMMENT '机构全称',
                                    `org_abr` varchar(20) DEFAULT NULL COMMENT '机构简称',
                                    `org_tpcd` varchar(9) DEFAULT NULL COMMENT '机构类型',
                                    `org_stcd` char(1) DEFAULT NULL COMMENT '机构状态,1未营业、2正常营业、3暂停营业、4终止营业、5已除名',
                                    `org_parent_no` varchar(20) DEFAULT NULL COMMENT '机构父节点编号',
                                    `sort` varchar(20) DEFAULT NULL COMMENT '机构显示顺序',
                                    remark VARCHAR(500) DEFAULT null  COMMENT '备注',
                                    `create_time` datetime DEFAULT NULL COMMENT '创建时间',
                                    `creator` bigint(20) DEFAULT NULL COMMENT '创建人',
                                    `update_time` datetime DEFAULT NULL COMMENT '更新时间',
                                    `updater` bigint(20) DEFAULT NULL COMMENT '更新人',
                                    `org_create_time` datetime DEFAULT NULL COMMENT '机构创建时间',
                                    `org_stop_time` datetime DEFAULT NULL COMMENT '机构停运时间',
                                    PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='机构表';
-- ----------------------------
-- 添加机构用户关系表
-- ----------------------------
DROP TABLE IF EXISTS `jsh_orga_user_rel`;
CREATE TABLE `jsh_orga_user_rel` (
                                     `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
                                     `orga_id` bigint(20) NOT NULL  COMMENT '机构id',
                                     `user_id` bigint(20) NOT NULL COMMENT '用户id',
                                     `user_blng_orga_dspl_seq` varchar(20) DEFAULT NULL COMMENT '用户在所属机构中显示顺序',
                                     `delete_flag` char(1) DEFAULT 0 COMMENT '删除标记，0未删除，1删除',
                                     `create_time` datetime DEFAULT NULL COMMENT '创建时间',
                                     `creator` bigint(20) DEFAULT NULL COMMENT '创建人',
                                     `update_time` datetime DEFAULT NULL COMMENT '更新时间',
                                     `updater` bigint(20) DEFAULT NULL COMMENT '更新人',
                                     PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8 COMMENT='机构用户关系表';
-- ----------------------------
-- 添加机构管理菜单
-- 插入数据前判断，防止数据重复插入
-- ----------------------------
INSERT INTO `jsh_functions`(`Number`, `Name`, `PNumber`, `URL`, `State`, `Sort`, `Enabled`, `Type`, `PushBtn`)
select '000108', '机构管理', '0001', '../manage/organization.html', b'1', '0139', b'1', '电脑版', '' from dual where not exists
    (select * from jsh_functions where  Number='000108' and PNumber='0001');
-- ----------------------------
-- 添加根机构
-- 插入时判断对应数据是否存在，防止多次执行产生重复数据
-- ----------------------------
INSERT INTO jsh_organization (org_no, org_full_name, org_abr, org_tpcd, org_stcd, org_parent_no, sort, remark, create_time, creator, update_time, updater, org_create_time, org_stop_time)
select '01', '根机构', '根机构', NULL, '2', '-1', '1', '根机构，初始化存在', NULL, NULL, NULL, NULL, NULL, NULL from dual where not exists
    (select * from jsh_organization where org_no='01' and org_abr='根机构' and org_parent_no='-1'  );
-- ----------------------------
-- 时间：2019年3月9日
-- version：1.0.6
-- 此次更新
-- 整改jsh_systemconfig表的字段
-- ----------------------------
alter table jsh_systemconfig drop type;
alter table jsh_systemconfig drop name;
alter table jsh_systemconfig drop value;
alter table jsh_systemconfig drop description;
alter table jsh_systemconfig add company_name varchar(50) DEFAULT null COMMENT '公司名称';
alter table jsh_systemconfig add company_contacts varchar(20) DEFAULT null COMMENT '公司联系人';
alter table jsh_systemconfig add company_address varchar(50) DEFAULT null COMMENT '公司地址';
alter table jsh_systemconfig add company_tel varchar(20) DEFAULT null COMMENT '公司电话';
alter table jsh_systemconfig add company_fax varchar(20) DEFAULT null COMMENT '公司传真';
alter table jsh_systemconfig add company_post_code varchar(20) DEFAULT null COMMENT '公司邮编';
delete from jsh_systemconfig;
insert into jsh_systemconfig (`company_name`, `company_contacts`, `company_address`, `company_tel`, `company_fax`, `company_post_code`) values("南通jshERP公司","张三","南通市通州区某某路","0513-10101010","0513-18181818","226300");

-- ----------------------------
-- 时间：2019年3月9日
-- version：1.0.7
-- 改管理员的功能权限
-- ----------------------------
update jsh_userbusiness SET
    Value = '[13][12][16][243][14][15][234][236][22][23][220][240][25][217][218][26][194][195][31][59][207][208][209][226][227][228][229][235][237][210][211][241][33][199][242][41][200][201][202][40][232][233][197][203][204][205][206][212]'
where Id = 5;
-- ----------------------------
-- 给订单功能加审核和反审核的功能按钮权限
-- ----------------------------
update jsh_functions SET PushBtn = '3' where Number = '050202' and PNumber = '0502';
update jsh_functions SET PushBtn = '3' where Number = '060301' and PNumber = '0603';
-- ----------------------------
-- 改管理员的按钮权限
-- ----------------------------
update jsh_userbusiness SET
    BtnStr = '[{"funId":"25","btnStr":"1"},{"funId":"217","btnStr":"1"},{"funId":"218","btnStr":"1"},{"funId":"241","btnStr":"3"},{"funId":"242","btnStr":"3"}]'
where Id = 5;

-- ----------------------------
-- 时间：2019年3月10日
-- version：1.0.8
-- 改状态字段的类型，增加关联单据字段
-- ----------------------------
alter table jsh_depot_head change Status Status varchar(1) DEFAULT '0' COMMENT '状态，0未审核、1已审核、2已转采购|销售';
alter table jsh_depot_head add `LinkNumber` varchar(50) DEFAULT null COMMENT '关联订单号';
-- ----------------------------
-- 时间：2019年3月12日
-- version：1.0.9
-- 此次更新
-- 1、根据本地用户表中现有部门生成机构表数据，同时重建机构和用户的关联关系
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
DROP FUNCTION IF EXISTS `_buildOrgAndOrgUserRel`;
DELIMITER ;;
CREATE FUNCTION `_buildOrgAndOrgUserRel` (name varchar(50)) RETURNS mediumtext CHARSET utf8
begin

declare _org_full_name varchar(500); -- 机构全称
declare _org_abr varchar(20);  -- 机构简称
declare _sort int default 0;
declare _success_msg varchar(50) default '重建机构及机构用户关系成功'; -- 机构全称
 -- 遍历数据结束标志
declare done int DEFAULT 0;
-- 获取用户表中唯一的部门信息列表
declare orgCur cursor for select distinct department from jsh_user where department!='' and department is not null;

-- 将结束标志绑定到游标
declare continue handler for not found set done = 1;
  -- 循环部门信息列表在机构表插入数据
  -- 打开游标
open orgCur;
-- 开始循环
read_loop: loop
    -- 提取游标里的数据，这里只有一个，多个的话也一样；
    fetch orgCur into _org_full_name;
    -- 声明结束的时候
    if done=1 then
      leave read_loop;
end if;
    -- 这里做你想做的循环的事件
    if length(_org_full_name)<=20 then
			set _org_abr=_org_full_name;
else
			set _org_abr=left(_org_full_name,20);
end if;
	set _sort=_sort+1;
insert into jsh_organization (org_full_name, org_abr,  org_stcd, org_parent_no, sort, remark)
values (_org_full_name,_org_abr, '1', '01', _sort, '机构表初始化');
begin
			declare _userId bigint;
			declare _orgId bigint;
			 -- 遍历数据结束标志
			declare ogrUserRelDone int DEFAULT 0;
			-- 根据用户表和机构表部门关联关系，重建用户和机构关联关系
			declare ogrUserRelCur cursor for select user.id as userId,org.id as orgId from jsh_user user,jsh_organization org
                                             where 1=1  and user.department=org.org_full_name and user.department =_org_full_name;
-- 将结束标志绑定到游标
declare continue handler for not found set ogrUserRelDone = 1;
			-- 打开游标
open ogrUserRelCur;
-- 开始循环
rel_read_loop: loop
			    -- 提取游标里的数据，这里只有一个，多个的话也一样；
			    fetch ogrUserRelCur into _userId,_orgId;
			    -- 声明结束的时候
			    if ogrUserRelDone=1 then
			      leave rel_read_loop;
end if;
insert into `jsh_orga_user_rel`(`orga_id`, `user_id`, `delete_flag`) VALUES (_orgId,_userId,'0');

end loop rel_read_loop;
		  -- 关闭游标
close ogrUserRelCur;
end;

end loop read_loop;
  -- 关闭游标
close orgCur;

-- 清空用户表中的部门信息
update jsh_user set department=null;

return _success_msg;
end
;;
DELIMITER ;
-- ----------------------------
-- 初始化机构数据，重建机构用户关系
-- ----------------------------
select _buildOrgAndOrgUserRel('初始化机构数据，重建机构用户关系') from dual;
-- ----------------------------
-- 删除一次性函数
-- ----------------------------
DROP FUNCTION _buildOrgAndOrgUserRel;

-- ----------------------------
-- 时间：2019年3月13日
-- version：1.0.10
-- 此次更新
-- 1、设置用户表的用户状态status默认值为0
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------

alter table jsh_user change Status Status tinyint(4) DEFAULT '0' COMMENT '状态，0：正常，1：删除，2封禁';
update jsh_user set status='0' where status is null;
-- ----------------------------
-- 设置根目录编号为1
-- ----------------------------
update jsh_materialcategory set serial_no='1' where id='1';

-- ----------------------------
-- 时间：2019年3月18日
-- version：1.0.11
-- 此次更新
-- 1、批量增加大部分表的tenant_id租户字段
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
alter table jsh_account add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_accounthead add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_accountitem add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_asset add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_assetcategory add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_assetname add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_depot add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_depot_head add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_depot_item add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_inoutitem add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_log add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_material add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_materialcategory add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_orga_user_rel add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_organization add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_person add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_role add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_serial_number add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_supplier add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_systemconfig add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_unit add tenant_id bigint(20) DEFAULT null COMMENT '租户id';
alter table jsh_user add tenant_id bigint(20) DEFAULT null COMMENT '租户id';

-- ----------------------------
-- 时间：2019年3月27日
-- version：1.0.12
-- 此次更新
-- 添加删除标记，将物理删除修改为逻辑删除
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
-- 角色表	jsh_role
alter table jsh_role add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 用户 角色 模块关系表	jsh_userbusiness
alter table jsh_userbusiness add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 功能模块表	jsh_functions
alter table jsh_functions add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 应用表	jsh_app
alter table jsh_app add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 产品表	jsh_material
alter table jsh_material add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 产品扩展字段表	jsh_materialproperty
alter table jsh_materialproperty add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 经手人表	jsh_person
alter table jsh_person add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 供应商 客户信息表	jsh_supplier
alter table jsh_supplier add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 系统参数表	jsh_systemconfig
alter table jsh_systemconfig add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 多单位表	jsh_unit
alter table jsh_unit add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 仓库表	jsh_depot
alter table jsh_depot add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 账户信息表	jsh_account
alter table jsh_account add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 财务主表	jsh_accounthead
alter table jsh_accounthead add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 财务子表	jsh_accountitem
alter table jsh_accountitem add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 资产记录表	jsh_asset
alter table jsh_asset add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 资产类型表	jsh_assetcategory
alter table jsh_assetcategory add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 资产信息表	jsh_assetname
alter table jsh_assetname add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 单据主表	jsh_depot_head
alter table jsh_depot_head add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 单据子表	jsh_depot_item
alter table jsh_depot_item add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
-- 收支项目表	jsh_inoutitem
alter table jsh_inoutitem add  delete_Flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

-- ----------------------------
-- 时间：2019年4月11日
-- version：1.0.13
-- 此次更新
-- 删除所有外键
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------

-- ----------------------------
-- 删除财务主表对应外键约束
-- ----------------------------
ALTER TABLE jsh_accounthead DROP FOREIGN KEY FK9F4C0D8DAAE50527;
ALTER TABLE jsh_accounthead DROP FOREIGN KEY FK9F4C0D8DB610FC06;
ALTER TABLE jsh_accounthead DROP FOREIGN KEY FK9F4C0D8DC4170B37;
-- ----------------------------
-- 删除财务子表对应外键约束
-- ----------------------------
ALTER TABLE jsh_accountitem DROP FOREIGN KEY FK9F4CBAC0AAE50527;
ALTER TABLE jsh_accountitem DROP FOREIGN KEY FK9F4CBAC0C5FE6007;
ALTER TABLE jsh_accountitem DROP FOREIGN KEY FK9F4CBAC0D203EDC5;
-- ----------------------------
-- 删除资产记录表对应外键约束
-- ----------------------------
ALTER TABLE jsh_asset DROP FOREIGN KEY FK353690ED27D23FE4;
ALTER TABLE jsh_asset DROP FOREIGN KEY FK353690ED3E226853;
ALTER TABLE jsh_asset DROP FOREIGN KEY FK353690ED61FE182C;
ALTER TABLE jsh_asset DROP FOREIGN KEY FK353690ED9B6CB285;
ALTER TABLE jsh_asset DROP FOREIGN KEY FK353690EDAD45B659;
-- ----------------------------
-- 删除资产信息表对应外键约束
-- ----------------------------
ALTER TABLE jsh_assetname DROP FOREIGN KEY FKA4ADCCF866BC8AD3;
-- ----------------------------
-- 删除单据主表对应外键约束
-- ----------------------------
ALTER TABLE jsh_depot_head DROP FOREIGN KEY FK2A80F214AAE50527;
ALTER TABLE jsh_depot_head DROP FOREIGN KEY jsh_depot_head_ibfk_1;
ALTER TABLE jsh_depot_head DROP FOREIGN KEY jsh_depot_head_ibfk_4;
ALTER TABLE jsh_depot_head DROP FOREIGN KEY jsh_depot_head_ibfk_5;
-- ----------------------------
-- 删除单据子表对应外键约束
-- ----------------------------
ALTER TABLE jsh_depot_item DROP FOREIGN KEY FK2A819F47729F5392;
ALTER TABLE jsh_depot_item DROP FOREIGN KEY FK2A819F479485B3F5;
ALTER TABLE jsh_depot_item DROP FOREIGN KEY jsh_depot_item_ibfk_2;
-- ----------------------------
-- 删除操作日志表对应外键约束
-- ----------------------------
ALTER TABLE jsh_log DROP FOREIGN KEY FKF2696AA13E226853;
-- ----------------------------
-- 删除产品表对应外键约束
-- ----------------------------
ALTER TABLE jsh_material DROP FOREIGN KEY FK675951272AB6672C;
ALTER TABLE jsh_material DROP FOREIGN KEY jsh_material_ibfk_1;

-- ----------------------------
-- 时间：2019年4月30日
-- version：1.0.14
-- 此次更新
-- 增加仓库默认功能 增加库存预警功能
-- 特别提醒：之后的sql都是在之前基础上迭代，可以对已存在的系统进行数据保留更新
-- ----------------------------
alter table jsh_depot add  is_default bit(1) DEFAULT NULL COMMENT '是否默认';
insert into `jsh_functions`(`Number`, `Name`, `PNumber`, `URL`, `State`, `Sort`, `Enabled`, `Type`, `PushBtn`)
select '030112', '库存预警', '0301', '../reports/stock_warning_report.html', b'0', '0670', b'1', '电脑版', '' from dual where not exists
    (select * from jsh_functions where  Number='030112' and PNumber='0301');

-- ----------------------------
-- 改管理员的功能权限
-- ----------------------------
update jsh_userbusiness SET Type = 'RoleFunctions', KeyId = '4',
                            Value = '[13][12][16][243][14][15][234][236][22][23][220][240][25][217][218][26][194][195][31][59][207][208][209][226][227][228][229][235][237][244][210][211][241][33][199][242][41][200][201][202][40][232][233][197][203][204][205][206][212]'
where Id = 5;

-- ----------------------------
-- 给app的功能增加代号 在功能表增加个人信息
-- ----------------------------
update jsh_app SET Number = '02' where name='个人信息';
insert into `jsh_functions`(`Number`, `Name`, `PNumber`, `URL`, `State`, `Sort`, `Enabled`, `Type`, `PushBtn`)
select '02', '个人信息', '0', '', b'1', '0005', b'1', '电脑版', '' from dual where not exists
    (select * from jsh_functions where  Number='02' and PNumber='0');

-- ----------------------------
-- 时间：2019年6月23日
-- 增加新手引导模块
-- ----------------------------
INSERT INTO `jsh_app` VALUES ('28', '09', '新手引导', 'app', 'userHelp.png', '../user/userHelp.html', '1000', '500', '\0', '\0', '\0', 'dock', '210', '', '', '0');
INSERT INTO `jsh_functions` VALUES ('246', '09', '新手引导', '0', '', '', '0115', '', '电脑版', '', '0');
update jsh_userbusiness SET Value = '[3][6][7][22][23][24][25][26][27][28]'
where Type = 'RoleAPP' and (KeyId = '4' or KeyId = '10');
update jsh_userbusiness SET
    Value = '[245][13][12][16][243][14][15][234][236][22][23][220][240][25][217][218][26][194][195][31][59][207][208][209][226][227][228][229][235][237][244][210][211][241][33][199][242][41][200][201][202][40][232][233][197][203][204][205][206][212][246]'
where Type = 'RoleFunctions' and KeyId = '4';
update jsh_userbusiness SET
    Value = '[245][13][243][14][15][234][22][23][220][240][25][217][218][26][194][195][31][59][207][208][209][226][227][228][229][235][237][244][210][211][241][33][199][242][41][200][201][202][40][232][233][197][203][204][205][206][212][246]'
where Type = 'RoleFunctions' and KeyId = '10';


-- ----------------------------
-- 时间：2019年6月26日
-- 删除多余的资产相关表
-- ----------------------------
drop table jsh_asset;
drop table jsh_assetcategory;
drop table jsh_assetname;


-- ----------------------------
-- 时间：2019年6月27日
-- 增加租户表
-- ----------------------------
DROP TABLE IF EXISTS `jsh_tenant`;
CREATE TABLE `jsh_tenant` (
                              `id` bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键',
                              `tenant_id` bigint(20) DEFAULT NULL COMMENT '用户id',
                              `login_name` varchar(255) DEFAULT NULL COMMENT '登录名',
                              `user_num_limit` int(11) DEFAULT NULL COMMENT '用户数量限制',
                              `bills_num_limit` int(11) DEFAULT NULL COMMENT '单据数量限制',
                              `create_time` datetime DEFAULT NULL COMMENT '创建时间',
                              PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=81 DEFAULT CHARSET=utf8 COMMENT='租户';

-- ----------------------------
-- 时间：2019年6月27日
-- 给租户表增加数据
-- ----------------------------
INSERT INTO `jsh_tenant` VALUES ('13', '63', 'jsh', '20', '2000', null);

-- ----------------------------
-- 时间：2019年7月10日
-- 删除函数
-- ----------------------------
DROP FUNCTION IF EXISTS `_nextval`;

-- ----------------------------
-- 时间：2019年8月1日
-- 增加仓库和客户的启用标记
-- ----------------------------
alter table jsh_systemconfig add  customer_flag varchar(1) DEFAULT '0' COMMENT '客户启用标记，0未启用，1启用' after company_post_code;
alter table jsh_systemconfig add  depot_flag varchar(1) DEFAULT '0' COMMENT '仓库启用标记，0未启用，1启用' after company_post_code;

-- ----------------------------
-- 时间：2019年9月13日
-- 给功能表增加icon字段
-- ----------------------------
alter table jsh_functions add  icon varchar(50) DEFAULT NULL COMMENT '图标' after PushBtn;

-- ----------------------------
-- 时间：2019年9月13日
-- 创建消息表
-- ----------------------------
CREATE TABLE `jsh_msg` (
                           `id`  bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键' ,
                           `msg_title`  varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息标题' ,
                           `msg_content`  varchar(500) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息内容' ,
                           `create_time`  datetime NULL DEFAULT NULL COMMENT '创建时间' ,
                           `type`  varchar(20) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '消息类型' ,
                           `status`  varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '状态，1未读 2已读' ,
                           `tenant_id`  bigint(20) NULL DEFAULT NULL COMMENT '租户id' ,
                           `delete_Flag`  varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '删除标记，0未删除，1删除' ,
                           PRIMARY KEY (`id`)
)
    ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='消息表'
AUTO_INCREMENT=2
ROW_FORMAT=COMPACT
;

-- ----------------------------
-- 时间：2019年9月13日
-- 删除表 jsh_app  databasechangelog databasechangeloglock
-- ----------------------------
drop table databasechangelog;
drop table databasechangeloglock;
drop table jsh_app;

-- ----------------------------
-- 时间：2019年11月28日
-- 单据编号表-改表名
-- ----------------------------
ALTER TABLE tbl_sequence RENAME TO jsh_sequence;

-- ----------------------------
-- 增加产品初始库存表
-- 时间 2019-11-28
-- by jishenghua
-- ----------------------------
CREATE TABLE `jsh_material_stock` (
                                      `id`  bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键' ,
                                      `material_id`  bigint(20) NULL DEFAULT NULL COMMENT '产品id' ,
                                      `depot_id`  bigint(20) NULL DEFAULT NULL COMMENT '仓库id' ,
                                      `number`  decimal(24,6) NULL DEFAULT NULL COMMENT '初始库存数量' ,
                                      `tenant_id`  bigint(20) NULL DEFAULT NULL COMMENT '租户id' ,
                                      `delete_fag`  varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '删除标记，0未删除，1删除' ,
                                      PRIMARY KEY (`id`)
)
    ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='产品初始库存'
AUTO_INCREMENT=48
ROW_FORMAT=COMPACT
;

-- ----------------------------
-- 增加商品扩展信息表
-- 时间 2020-02-15
-- by jishenghua
-- ----------------------------
CREATE TABLE `jsh_material_extend` (
                                       `id`  bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键' ,
                                       `material_id`  bigint(20) NULL DEFAULT NULL COMMENT '商品id' ,
                                       `bar_code`  varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '商品条码' ,
                                       `commodity_unit`  varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '商品单位' ,
                                       `purchase_decimal`  decimal(24,6) NULL DEFAULT NULL COMMENT '采购价格' ,
                                       `commodity_decimal`  decimal(24,6) NULL DEFAULT NULL COMMENT '零售价格' ,
                                       `wholesale_decimal`  decimal(24,6) NULL DEFAULT NULL COMMENT '销售价格' ,
                                       `low_decimal`  decimal(24,6) NULL DEFAULT NULL COMMENT '最低售价' ,
                                       `create_time`  datetime NULL DEFAULT NULL COMMENT '创建日期' ,
                                       `create_serial`  varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '创建人编码' ,
                                       `update_serial`  varchar(50) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT NULL COMMENT '更新人编码' ,
                                       `update_time`  bigint(20) NULL DEFAULT NULL COMMENT '更新时间戳' ,
                                       `tenant_id`  bigint(20) NULL DEFAULT NULL COMMENT '租户id' ,
                                       `delete_Flag`  varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '删除标记，0未删除，1删除' ,
                                       PRIMARY KEY (`id`)
)
    ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='产品价格扩展'
AUTO_INCREMENT=1
ROW_FORMAT=COMPACT
;

-- ----------------------------
-- 给单据明细表增加商品扩展id
-- 时间 2020-02-16
-- by jishenghua
-- ----------------------------
alter table jsh_depot_item add material_extend_id bigint(20) DEFAULT NULL COMMENT '商品扩展id' after MaterialId;

-- ----------------------------
-- 给单据主表删除字段ProjectId 和 AllocationProjectId
-- 时间 2020-02-18
-- by jishenghua
-- ----------------------------
alter table jsh_depot_head drop column ProjectId;
alter table jsh_depot_head drop column AllocationProjectId;

-- ----------------------------
-- 给计量单位表增加基础单位、副单位、比例三个字段
-- 时间 2020-03-24
-- by jishenghua
-- ----------------------------
alter table jsh_unit add basic_unit varchar(50) DEFAULT NULL COMMENT '基础单位' after UName;
alter table jsh_unit add other_unit varchar(50) DEFAULT NULL COMMENT '副单位' after basic_unit;
alter table jsh_unit add ratio INT DEFAULT NULL COMMENT '比例' after other_unit;

-- ----------------------------
-- 时间：2020年03月31日
-- by jishenghua
-- 给用户表增加 登录用户名 字段
-- ----------------------------
alter table jsh_user change loginame login_name varchar(255) NOT NULL COMMENT '登录用户名';

-- ----------------------------
-- 时间：2020年04月12日
-- by jishenghua
-- 给功能表增加插件管理
-- ----------------------------
INSERT INTO `jsh_functions` VALUES (245,'000107', '插件管理', '0001', '/pages/manage/plugin.html', '\0', '0170', '', '电脑版', '', 'icon-notebook', '0');

-- ----------------------------
-- 时间：2020年04月25日
-- by jishenghua
-- 给商品扩展表增加 是否默认基础单位 字段
-- ----------------------------
alter table jsh_material_extend add default_flag VARCHAR(1) DEFAULT 1 COMMENT '是否为默认单位，1是，0否' after low_decimal;

-- ----------------------------
-- 时间：2020年05月04日
-- by jishenghua
-- 删除商品表的多价格相关的字段
-- ----------------------------
alter table jsh_material drop Packing;
alter table jsh_material drop RetailPrice;
alter table jsh_material drop LowPrice;
alter table jsh_material drop PresetPriceOne;
alter table jsh_material drop PresetPriceTwo;
alter table jsh_material drop FirstOutUnit;
alter table jsh_material drop FirstInUnit;
alter table jsh_material drop PriceStrategy;

-- ----------------------------
-- 时间：2020年6月18日
-- 增加负库存的启用标记
-- ----------------------------
alter table jsh_systemconfig add minus_stock_flag varchar(1) DEFAULT '0' COMMENT '负库存启用标记，0未启用，1启用' after customer_flag;

-- ----------------------------
-- 时间 2020年07月13日
-- by jishenghua
-- 增加产品当前库存表
-- ----------------------------
CREATE TABLE `jsh_material_current_stock` (
                                              `id`  bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键' ,
                                              `material_id`  bigint(20) NULL DEFAULT NULL COMMENT '产品id' ,
                                              `depot_id`  bigint(20) NULL DEFAULT NULL COMMENT '仓库id' ,
                                              `current_number`  decimal(24,6) NULL DEFAULT NULL COMMENT '当前库存数量' ,
                                              `tenant_id`  bigint(20) NULL DEFAULT NULL COMMENT '租户id' ,
                                              `delete_flag`  varchar(1) CHARACTER SET utf8 COLLATE utf8_general_ci NULL DEFAULT '0' COMMENT '删除标记，0未删除，1删除' ,
                                              PRIMARY KEY (`id`)
)
    ENGINE=InnoDB
DEFAULT CHARACTER SET=utf8 COLLATE=utf8_general_ci
COMMENT='产品当前库存'
AUTO_INCREMENT=1
ROW_FORMAT=COMPACT
;

-- --------------------------------------------------------
-- 时间 2020年07月13日
-- by jishenghua
-- 修改jsh_material_stock的表名为jsh_material_initial_stock
-- 修改jsh_material_initial_stock表的删除字段
-- --------------------------------------------------------
alter table jsh_material_stock rename to jsh_material_initial_stock;
alter table jsh_material_initial_stock change delete_fag delete_flag varchar(1) NULL DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

-- --------------------------------------------------------
-- 时间 2020年07月20日
-- by jishenghua
-- 优化表和字段的格式
-- --------------------------------------------------------
alter table jsh_log change userID user_id bigint(20) DEFAULT NULL COMMENT '用户id';
alter table jsh_log change clientIP client_ip varchar(50) DEFAULT NULL COMMENT '客户端IP';
alter table jsh_log change createtime create_time datetime DEFAULT NULL COMMENT '创建时间';
alter table jsh_log change contentdetails content varchar(1000) DEFAULT NULL COMMENT '详情';
alter table jsh_log drop column remark;

alter table jsh_materialcategory rename to jsh_material_category;
alter table jsh_material_category change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_material_category change Name name varchar(50) DEFAULT NULL COMMENT '名称';
alter table jsh_material_category change CategoryLevel category_level smallint(6) DEFAULT NULL COMMENT '等级';
alter table jsh_material_category change ParentId parent_id bigint(20) DEFAULT NULL COMMENT '上级id';

alter table jsh_materialproperty rename to jsh_material_property;
alter table jsh_material_property change nativeName native_name varchar(50) DEFAULT NULL COMMENT '原始名称';
alter table jsh_material_property change anotherName another_name varchar(50) DEFAULT NULL COMMENT '别名';
alter table jsh_material_property change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_role change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_role change Name name varchar(50) DEFAULT NULL COMMENT '名称';
alter table jsh_role change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_person change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_person change Type type varchar(20) DEFAULT NULL COMMENT '类型';
alter table jsh_person change Name name varchar(50) DEFAULT NULL COMMENT '姓名';
alter table jsh_person change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_systemconfig rename to jsh_system_config;
alter table jsh_system_config change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_account change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_account change Name name varchar(50) DEFAULT NULL COMMENT '名称';
alter table jsh_account change SerialNo serial_no varchar(50) DEFAULT NULL COMMENT '编号';
alter table jsh_account change InitialAmount initial_amount decimal(24,6) DEFAULT NULL COMMENT '期初金额';
alter table jsh_account change CurrentAmount current_amount decimal(24,6) DEFAULT NULL COMMENT '当前余额';
alter table jsh_account change Remark remark varchar(100) DEFAULT NULL COMMENT '备注';
alter table jsh_account change IsDefault is_default bit(1) DEFAULT NULL COMMENT '是否默认';
alter table jsh_account change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_functions rename to jsh_function;
alter table jsh_function change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_function change Number number varchar(50) DEFAULT NULL COMMENT '编号';
alter table jsh_function change Name name varchar(50) DEFAULT NULL COMMENT '名称';
alter table jsh_function change PNumber parent_number varchar(50) DEFAULT NULL COMMENT '上级编号';
alter table jsh_function change URL url varchar(100) DEFAULT NULL COMMENT '链接';
alter table jsh_function change State state bit(1) DEFAULT NULL COMMENT '收缩';
alter table jsh_function change Sort sort varchar(50) DEFAULT NULL COMMENT '排序';
alter table jsh_function change Enabled enabled bit(1) DEFAULT NULL COMMENT '启用';
alter table jsh_function change Type type varchar(50) DEFAULT NULL COMMENT '类型';
alter table jsh_function change PushBtn push_btn varchar(50) DEFAULT NULL COMMENT '功能按钮';
alter table jsh_function change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_userbusiness rename to jsh_user_business;
alter table jsh_user_business change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_user_business change Type type varchar(50) DEFAULT NULL COMMENT '类别';
alter table jsh_user_business change KeyId key_id varchar(50) DEFAULT NULL COMMENT '主id';
alter table jsh_user_business change Value value varchar(10000) DEFAULT NULL COMMENT '值';
alter table jsh_user_business change BtnStr btn_str varchar(2000) DEFAULT NULL COMMENT '按钮权限';
alter table jsh_user_business change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_unit change UName name varchar(50) DEFAULT NULL COMMENT '名称，支持多单位';
alter table jsh_unit change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_inoutitem rename to jsh_in_out_item;
alter table jsh_in_out_item change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_in_out_item change Name name varchar(50) DEFAULT NULL COMMENT '名称';
alter table jsh_in_out_item change Type type varchar(20) DEFAULT NULL COMMENT '类型';
alter table jsh_in_out_item change Remark remark varchar(100) DEFAULT NULL COMMENT '备注';
alter table jsh_in_out_item change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_serial_number change material_Id material_id bigint(20) DEFAULT NULL COMMENT '产品表id';
alter table jsh_serial_number change serial_Number serial_number varchar(64) DEFAULT NULL COMMENT '序列号';
alter table jsh_serial_number change is_Sell is_sell varchar(1) DEFAULT '0' COMMENT '是否卖出，0未卖出，1卖出';
alter table jsh_serial_number change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
alter table jsh_serial_number change create_Time create_time datetime DEFAULT NULL COMMENT '创建时间';
alter table jsh_serial_number change update_Time update_time datetime DEFAULT NULL COMMENT '更新时间';
alter table jsh_serial_number change depothead_Id depot_head_id bigint(20) DEFAULT NULL COMMENT '单据主表id，用于跟踪序列号流向';

alter table jsh_supplier change phonenum phone_num varchar(30) DEFAULT NULL COMMENT '联系电话';
alter table jsh_supplier change AdvanceIn advance_in decimal(24,6) DEFAULT '0.000000' COMMENT '预收款';
alter table jsh_supplier change BeginNeedGet begin_need_get decimal(24,6) DEFAULT NULL COMMENT '期初应收';
alter table jsh_supplier change BeginNeedPay begin_need_pay decimal(24,6) DEFAULT NULL COMMENT '期初应付';
alter table jsh_supplier change AllNeedGet all_need_get decimal(24,6) DEFAULT NULL COMMENT '累计应收';
alter table jsh_supplier change AllNeedPay all_need_pay decimal(24,6) DEFAULT NULL COMMENT '累计应付';
alter table jsh_supplier change taxNum tax_num varchar(50) DEFAULT NULL COMMENT '纳税人识别号';
alter table jsh_supplier change bankName bank_name varchar(50) DEFAULT NULL COMMENT '开户行';
alter table jsh_supplier change accountNumber account_number varchar(50) DEFAULT NULL COMMENT '账号';
alter table jsh_supplier change taxRate tax_rate decimal(24,6) DEFAULT NULL COMMENT '税率';
alter table jsh_supplier change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_accounthead rename to jsh_account_head;
alter table jsh_account_head change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_account_head change Type type varchar(50) DEFAULT NULL COMMENT '类型(支出/收入/收款/付款/转账)';
alter table jsh_account_head change OrganId organ_id bigint(20) DEFAULT NULL COMMENT '单位Id(收款/付款单位)';
alter table jsh_account_head change HandsPersonId hands_person_id bigint(20) DEFAULT NULL COMMENT '经手人id';
alter table jsh_account_head change ChangeAmount change_amount decimal(24,6) DEFAULT NULL COMMENT '变动金额(优惠/收款/付款/实付)';
alter table jsh_account_head change TotalPrice total_price decimal(24,6) DEFAULT NULL COMMENT '合计金额';
alter table jsh_account_head change AccountId account_id bigint(20) DEFAULT NULL COMMENT '账户(收款/付款)';
alter table jsh_account_head change BillNo bill_no varchar(50) DEFAULT NULL COMMENT '单据编号';
alter table jsh_account_head change BillTime bill_time datetime DEFAULT NULL COMMENT '单据日期';
alter table jsh_account_head change Remark remark varchar(100) DEFAULT NULL COMMENT '备注';
alter table jsh_account_head change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_accountitem rename to jsh_account_item;
alter table jsh_account_item change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_account_item change HeaderId header_id bigint(20) NOT NULL COMMENT '表头Id';
alter table jsh_account_item change AccountId account_id bigint(20) DEFAULT NULL COMMENT '账户Id';
alter table jsh_account_item change InOutItemId in_out_item_id bigint(20) DEFAULT NULL COMMENT '收支项目Id';
alter table jsh_account_item change EachAmount each_amount decimal(24,6) DEFAULT NULL COMMENT '单项金额';
alter table jsh_account_item change Remark remark varchar(100) DEFAULT NULL COMMENT '单据备注';
alter table jsh_account_item change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_material change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_material change CategoryId category_id bigint(20) DEFAULT NULL COMMENT '产品类型id';
alter table jsh_material change Name name varchar(50) DEFAULT NULL COMMENT '名称';
alter table jsh_material change Mfrs mfrs varchar(50) DEFAULT NULL COMMENT '制造商';
alter table jsh_material change SafetyStock safety_stock decimal(24,6) DEFAULT NULL COMMENT '安全存量（KG）';
alter table jsh_material change Model model varchar(50) DEFAULT NULL COMMENT '型号';
alter table jsh_material change Standard standard varchar(50) DEFAULT NULL COMMENT '规格';
alter table jsh_material change Color color varchar(50) DEFAULT NULL COMMENT '颜色';
alter table jsh_material change Unit unit varchar(50) DEFAULT NULL COMMENT '单位-单个';
alter table jsh_material change Remark remark varchar(100) DEFAULT NULL COMMENT '备注';
alter table jsh_material change UnitId unit_id bigint(20) DEFAULT NULL COMMENT '计量单位Id';
alter table jsh_material change Enabled enabled bit(1) DEFAULT NULL COMMENT '启用 0-禁用  1-启用';
alter table jsh_material change OtherField1 other_field1 varchar(50) DEFAULT NULL COMMENT '自定义1';
alter table jsh_material change OtherField2 other_field2 varchar(50) DEFAULT NULL COMMENT '自定义2';
alter table jsh_material change OtherField3 other_field3 varchar(50) DEFAULT NULL COMMENT '自定义3';
alter table jsh_material change enableSerialNumber enable_serial_number varchar(1) DEFAULT '0' COMMENT '是否开启序列号，0否，1是';
alter table jsh_material change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_depothead rename to jsh_depot_head;
alter table jsh_depot_head change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_depot_head change Type type varchar(50) DEFAULT NULL COMMENT '类型(出库/入库)';
alter table jsh_depot_head change SubType sub_type varchar(50) DEFAULT NULL COMMENT '出入库分类';
alter table jsh_depot_head change DefaultNumber default_number varchar(50) DEFAULT NULL COMMENT '初始票据号';
alter table jsh_depot_head change Number number varchar(50) DEFAULT NULL COMMENT '票据号';
alter table jsh_depot_head change OperPersonName oper_person_name varchar(50) DEFAULT NULL COMMENT '操作员名字';
alter table jsh_depot_head change CreateTime create_time datetime DEFAULT NULL COMMENT '创建时间';
alter table jsh_depot_head change OperTime oper_time datetime DEFAULT NULL COMMENT '出入库时间';
alter table jsh_depot_head change OrganId organ_id bigint(20) DEFAULT NULL COMMENT '供应商id';
alter table jsh_depot_head change HandsPersonId hands_person_id bigint(20) DEFAULT NULL COMMENT '采购/领料-经手人id';
alter table jsh_depot_head change AccountId account_id bigint(20) DEFAULT NULL COMMENT '账户id';
alter table jsh_depot_head change ChangeAmount change_amount decimal(24,6) DEFAULT NULL COMMENT '变动金额(收款/付款)';
alter table jsh_depot_head change TotalPrice total_price decimal(24,6) DEFAULT NULL COMMENT '合计金额';
alter table jsh_depot_head change PayType pay_type varchar(50) DEFAULT NULL COMMENT '付款类型(现金、记账等)';
alter table jsh_depot_head change Remark remark varchar(1000) DEFAULT NULL COMMENT '备注';
alter table jsh_depot_head change Salesman sales_man varchar(50) DEFAULT NULL COMMENT '业务员（可以多个）';
alter table jsh_depot_head change AccountIdList account_id_list varchar(50) DEFAULT NULL COMMENT '多账户ID列表';
alter table jsh_depot_head change AccountMoneyList account_money_list varchar(200) DEFAULT NULL COMMENT '多账户金额列表';
alter table jsh_depot_head change Discount discount decimal(24,6) DEFAULT NULL COMMENT '优惠率';
alter table jsh_depot_head change DiscountMoney discount_money decimal(24,6) DEFAULT NULL COMMENT '优惠金额';
alter table jsh_depot_head change DiscountLastMoney discount_last_money decimal(24,6) DEFAULT NULL COMMENT '优惠后金额';
alter table jsh_depot_head change OtherMoney other_money decimal(24,6) DEFAULT NULL COMMENT '销售或采购费用合计';
alter table jsh_depot_head change OtherMoneyList other_money_list varchar(200) DEFAULT NULL COMMENT '销售或采购费用涉及项目Id数组（包括快递、招待等）';
alter table jsh_depot_head change OtherMoneyItem other_money_item varchar(200) DEFAULT NULL COMMENT '销售或采购费用涉及项目（包括快递、招待等）';
alter table jsh_depot_head change AccountDay account_day int(10) DEFAULT NULL COMMENT '结算天数';
alter table jsh_depot_head change Status status varchar(1) DEFAULT NULL COMMENT '状态，0未审核、1已审核、2已转采购|销售';
alter table jsh_depot_head change LinkNumber link_number varchar(50) DEFAULT NULL COMMENT '关联订单号';
alter table jsh_depot_head change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

alter table jsh_depotitem rename to jsh_depot_item;
alter table jsh_depot_item change Id id bigint(20) NOT NULL AUTO_INCREMENT COMMENT '主键';
alter table jsh_depot_item change HeaderId header_id bigint(20) NOT NULL COMMENT '表头Id';
alter table jsh_depot_item change MaterialId material_id bigint(20) NOT NULL COMMENT '商品Id';
alter table jsh_depot_item change MUnit material_unit varchar(20) DEFAULT NULL COMMENT '商品计量单位';
alter table jsh_depot_item change OperNumber oper_number decimal(24,6) DEFAULT NULL COMMENT '数量';
alter table jsh_depot_item change BasicNumber basic_number decimal(24,6) DEFAULT NULL COMMENT '基础数量，如kg、瓶';
alter table jsh_depot_item change UnitPrice unit_price decimal(24,6) DEFAULT NULL COMMENT '单价';
alter table jsh_depot_item change TaxUnitPrice tax_unit_price decimal(24,6) DEFAULT NULL COMMENT '含税单价';
alter table jsh_depot_item change AllPrice all_price decimal(24,6) DEFAULT NULL COMMENT '金额';
alter table jsh_depot_item change Remark remark varchar(200) DEFAULT NULL COMMENT '备注';
alter table jsh_depot_item change Img img varchar(50) DEFAULT NULL COMMENT '图片';
alter table jsh_depot_item change Incidentals incidentals decimal(24,6) DEFAULT NULL COMMENT '运杂费';
alter table jsh_depot_item change DepotId depot_id bigint(20) DEFAULT NULL COMMENT '仓库ID';
alter table jsh_depot_item change AnotherDepotId another_depot_id bigint(20) DEFAULT NULL COMMENT '调拨时，对方仓库Id';
alter table jsh_depot_item change TaxRate tax_rate decimal(24,6) DEFAULT NULL COMMENT '税率';
alter table jsh_depot_item change TaxMoney tax_money decimal(24,6) DEFAULT NULL COMMENT '税额';
alter table jsh_depot_item change TaxLastMoney tax_last_money decimal(24,6) DEFAULT NULL COMMENT '价税合计';
alter table jsh_depot_item change OtherField1 other_field1 varchar(50) DEFAULT NULL COMMENT '自定义字段1-名称';
alter table jsh_depot_item change OtherField2 other_field2 varchar(50) DEFAULT NULL COMMENT '自定义字段2-型号';
alter table jsh_depot_item change OtherField3 other_field3 varchar(50) DEFAULT NULL COMMENT '自定义字段3-制造商';
alter table jsh_depot_item change OtherField4 other_field4 varchar(50) DEFAULT NULL COMMENT '自定义字段4-名称';
alter table jsh_depot_item change OtherField5 other_field5 varchar(50) DEFAULT NULL COMMENT '自定义字段5-名称';
alter table jsh_depot_item change MType material_type varchar(20) DEFAULT NULL COMMENT '商品类型';
alter table jsh_depot_item change delete_Flag delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';

-- --------------------------------------------------------
-- 时间 2020年09月13日
-- by jishenghua
-- 给单据表增加操作员字段,去掉经手头姓名字段
-- --------------------------------------------------------
alter table jsh_depot_head add creator bigint(20) DEFAULT NULL COMMENT '操作员' after hands_person_id;
alter table jsh_account_head add creator bigint(20) DEFAULT NULL COMMENT '操作员' after hands_person_id;
alter table jsh_depot_head drop column oper_person_name;
update jsh_depot_head set creator=hands_person_id;


-- --------------------------------------------------------
-- 时间 2020年10月17日
-- by jishenghua
-- 增加平台表
-- --------------------------------------------------------
DROP TABLE IF EXISTS `jsh_platform_config`;
CREATE TABLE `jsh_platform_config` (
                                       `id` bigint(20) NOT NULL AUTO_INCREMENT,
                                       `platform_key` varchar(100) DEFAULT NULL COMMENT '关键词',
                                       `platform_key_info` varchar(100) DEFAULT NULL COMMENT '关键词名称',
                                       `platform_value` varchar(200) DEFAULT NULL COMMENT '值',
                                       PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COMMENT='平台参数';

INSERT INTO `jsh_platform_config` VALUES ('1', 'platform_name', '平台名称', '华夏ERP');
INSERT INTO `jsh_platform_config` VALUES ('2', 'activation_code', '激活码', null);

-- --------------------------------------------------------
-- 时间 2020年11月24日
-- by jishenghua
-- 给单据主表增加单据类型字段bill_type
-- --------------------------------------------------------
alter table jsh_depot_head add bill_type varchar(50) DEFAULT NULL COMMENT '单据类型' after pay_type;

-- --------------------------------------------------------
-- 时间 2021年1月19日
-- by jishenghua
-- 给功能表增加组件字段component
-- --------------------------------------------------------
alter table jsh_function add component varchar(100) DEFAULT NULL COMMENT '组件' after url;

-- --------------------------------------------------------
-- 时间 2021年2月13日
-- by jishenghua
-- 优化机构和商品类型表的字段
-- --------------------------------------------------------
alter table jsh_organization change org_parent_no parent_id bigint(20) DEFAULT NULL COMMENT '父机构id';
alter table jsh_organization change org_stcd delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
alter table jsh_organization drop column org_tpcd;
alter table jsh_organization drop column org_create_time;
alter table jsh_organization drop column org_stop_time;
alter table jsh_organization drop column creator;
alter table jsh_organization drop column updater;
alter table jsh_material_category drop column creator;
alter table jsh_material_category drop column updater;
alter table jsh_material_category change status delete_flag varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除';
update jsh_material_category set delete_flag='0';

-- --------------------------------------------------------
-- 时间 2021年6月1日
-- by jishenghua
-- 增加租户管理菜单
-- --------------------------------------------------------
INSERT INTO `jsh_function` (`id`, `number`, `name`, `parent_number`, `url`, `component`, `state`, `sort`, `enabled`, `type`, `push_btn`, `icon`, `delete_flag`) VALUES ('18', '000109', '租户管理', '0001', '/system/tenant', '/system/TenantList', b'0', '0167', b'1', '电脑版', '1', 'profile', '0');

-- --------------------------------------------------------
-- 时间 2021年6月19日
-- by jishenghua
-- 更新jsh_platform_config数据
-- --------------------------------------------------------
INSERT INTO `jsh_platform_config` (`id`, `platform_key`, `platform_key_info`, `platform_value`) VALUES ('3', 'platform_url', '官方网站', 'http://www.huaxiaerp.com/');

-- --------------------------------------------------------
-- 时间 2021年6月20日
-- by jishenghua
-- 将库存状态报表改为进销存统计报表
-- --------------------------------------------------------
update jsh_function set name='进销存统计', sort='0658' where id=59;

-- --------------------------------------------------------
-- 时间 2021年6月20日
-- by jishenghua
-- 增加商品库存报表
-- --------------------------------------------------------
INSERT INTO `jsh_function` (`number`, `name`, `parent_number`, `url`, `component`, `state`, `sort`, `enabled`, `type`, `push_btn`, `icon`, `delete_flag`) VALUES ('030113', '商品库存', '0301', '/report/material_stock', '/report/MaterialStock', b'0', '0605', b'1', '电脑版', '', 'profile', '0');

-- --------------------------------------------------------
-- 时间 2021年6月29日
-- by jishenghua
-- 给jsh_account_item增加字段进销存单据id 应收欠款 已收欠款
-- 给jsh_depot_head增加附件字段附件名称
-- 给jsh_account_head增加附件字段附件名称 优惠金额
-- --------------------------------------------------------
alter table jsh_account_item add bill_id bigint(20) DEFAULT NULL COMMENT '进销存单据id' after in_out_item_id;
alter table jsh_account_item add need_debt decimal(24,6) DEFAULT NULL COMMENT '应收欠款' after bill_id;
alter table jsh_account_item add finish_debt decimal(24,6) DEFAULT NULL COMMENT '已收欠款' after need_debt;
alter table jsh_depot_head add file_name varchar(500) DEFAULT NULL COMMENT '附件名称' after remark;
alter table jsh_account_head add file_name varchar(500) DEFAULT NULL COMMENT '附件名称' after remark;
alter table jsh_account_head add discount_money decimal(24,6) DEFAULT NULL COMMENT '优惠金额' after change_amount;

-- --------------------------------------------------------
-- 时间 2021年7月1日
-- by jishenghua
-- 给商品表增加附件名称字段
-- --------------------------------------------------------
alter table jsh_material add img_name varchar(500) DEFAULT NULL COMMENT '图片名称' after remark;

-- --------------------------------------------------------
-- 时间 2021年7月6日
-- by jishenghua
-- 给租户表增加字段enabled
-- --------------------------------------------------------
alter table jsh_tenant add enabled bit(1) DEFAULT 1 COMMENT '启用 0-禁用  1-启用' after bills_num_limit;

-- --------------------------------------------------------
-- 时间 2021年7月21日
-- by jishenghua
-- 增加商品属性表
-- --------------------------------------------------------
DROP TABLE IF EXISTS `jsh_material_attribute`;
CREATE TABLE `jsh_material_attribute` (
                                          `id` bigint(20) NOT NULL AUTO_INCREMENT,
                                          `attribute_field` varchar(50) DEFAULT NULL COMMENT '属性字段',
                                          `attribute_name` varchar(50) DEFAULT NULL COMMENT '属性名',
                                          `attribute_value` varchar(500) DEFAULT NULL COMMENT '属性值',
                                          `tenant_id` bigint(20) DEFAULT NULL COMMENT '租户id',
                                          `delete_flag` varchar(1) DEFAULT '0' COMMENT '删除标记，0未删除，1删除',
                                          PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8 COMMENT='产品属性表';

INSERT INTO `jsh_material_attribute` VALUES ('1', 'manyColor', '多颜色', '红色|橙色|黄色|绿色|蓝色|紫色', '63', '0');
INSERT INTO `jsh_material_attribute` VALUES ('2', 'manySize', '多尺寸', 'S|M|L|XL|XXL|XXXL', '63', '0');
INSERT INTO `jsh_material_attribute` VALUES ('3', 'other1', '自定义1', '小米|华为', '63', '0');
INSERT INTO `jsh_material_attribute` VALUES ('4', 'other2', '自定义2', null, '63', '0');
INSERT INTO `jsh_material_attribute` VALUES ('5', 'other3', '自定义3', null, '63', '0');

-- --------------------------------------------------------
-- 时间 2021年7月22日
-- by jishenghua
-- 增加多属性设置菜单
-- --------------------------------------------------------
INSERT INTO `jsh_function` (`id`, `number`, `name`, `parent_number`, `url`, `component`, `state`, `sort`, `enabled`, `type`, `push_btn`, `icon`, `delete_flag`) VALUES ('247', '010105', '多属性', '0101', '/material/material_attribute', '/material/MaterialAttributeList', '\0', '0250', '', '电脑版', '1', 'profile', '0');

-- --------------------------------------------------------
-- 时间 2021年7月22日
-- by jishenghua
-- 移除机构表的全名字段
-- 给商品扩展表加sku字段
-- 给单据主表移除多余字段
-- 给单据子表移除多余字段
-- --------------------------------------------------------
alter table jsh_organization drop column org_full_name;
alter table jsh_material_extend add sku varchar(50) DEFAULT NULL COMMENT '多属性' after commodity_unit;
alter table jsh_depot_head drop column hands_person_id;
alter table jsh_depot_head drop column other_money_list;
alter table jsh_depot_head drop column other_money_item;
alter table jsh_depot_head drop column account_day;
alter table jsh_depot_item drop column img;
alter table jsh_depot_item drop column incidentals;
alter table jsh_depot_item drop column other_field1;
alter table jsh_depot_item drop column other_field2;
alter table jsh_depot_item drop column other_field3;
alter table jsh_depot_item drop column other_field4;
alter table jsh_depot_item drop column other_field5;

-- --------------------------------------------------------
-- 时间 2021年7月27日
-- by jishenghua
-- 给单据子表加sku字段
-- --------------------------------------------------------
alter table jsh_depot_item add sku varchar(50) DEFAULT NULL COMMENT '多属性' after material_unit;

-- --------------------------------------------------------
-- 时间 2021年7月29日
-- by jishenghua
-- 增加调拨明细菜单
-- --------------------------------------------------------
INSERT INTO `jsh_function` VALUES ('248', '030150', '调拨明细', '0301', '/report/allocation_detail', '/report/AllocationDetail', '\0', '0646', '', '电脑版', '', 'profile', '0');

-- --------------------------------------------------------
-- 时间 2021年8月24日
-- by jishenghua
-- 给租户表加sku字段
-- 给租户表移除单据数量限制字段
-- --------------------------------------------------------
alter table jsh_tenant add type varchar(1) DEFAULT '0' COMMENT '租户类型，0免费租户，1付费租户' after bills_num_limit;
alter table jsh_tenant drop column bills_num_limit;
alter table jsh_tenant add expire_time datetime DEFAULT NULL COMMENT '到期时间' after create_time;

-- --------------------------------------------------------
-- 时间 2021年8月29日
-- by jishenghua
-- 给日志表的ip字段改长度
-- --------------------------------------------------------
alter table jsh_log change client_ip client_ip varchar(200) DEFAULT NULL COMMENT '客户端IP';

-- --------------------------------------------------------
-- 时间 2021年9月5日
-- by jishenghua
-- 给财务表增加状态字段，给历史数据赋值为0
-- --------------------------------------------------------
alter table jsh_account_head add status varchar(1) DEFAULT NULL COMMENT '状态，0未审核、1已审核' after file_name;
update jsh_account_head set status=0;

-- --------------------------------------------------------
-- 时间 2021年9月12日
-- by jishenghua
-- 插入jsh_platform_config数据，控制是否显示三联打印
-- --------------------------------------------------------
INSERT INTO `jsh_platform_config` (`id`, `platform_key`, `platform_key_info`, `platform_value`) VALUES ('4', 'bill_print_flag', '三联打印启用标记', '0');
INSERT INTO `jsh_platform_config` (`id`, `platform_key`, `platform_key_info`, `platform_value`) VALUES ('5', 'bill_print_url', '三联打印地址', '');

-- --------------------------------------------------------
-- 时间 2021年9月24日
-- by jishenghua
-- 修改单据主表的状态字段描述
-- --------------------------------------------------------
alter table jsh_depot_head change status status varchar(1) DEFAULT NULL COMMENT '状态，0未审核、1已审核、2完成采购|销售、3部分采购|销售';

-- --------------------------------------------------------
-- 时间 2021年9月27日
-- by jishenghua
-- 给商品表和单据字表增加字段
-- --------------------------------------------------------
alter table jsh_material add enable_batch_number varchar(1) DEFAULT 0 COMMENT '是否开启批号，0否，1是' after enable_serial_number;
alter table jsh_material add expiry_num int(10) DEFAULT NULL COMMENT '保质期天数' after unit_id;
alter table jsh_depot_item add sn_list varchar(2000) DEFAULT NULL COMMENT '序列号列表' after material_type;
alter table jsh_depot_item add batch_number varchar(100) DEFAULT NULL COMMENT '批号' after sn_list;
alter table jsh_depot_item add expiration_date datetime DEFAULT NULL COMMENT '有效日期' after batch_number;

-- --------------------------------------------------------
-- 时间 2021年9月27日
-- by jishenghua
-- 插入jsh_platform_config数据，配置租户续费地址
-- --------------------------------------------------------
INSERT INTO `jsh_platform_config` (`platform_key`, `platform_key_info`, `platform_value`) VALUES ('pay_fee_url', '租户续费地址', '');

-- --------------------------------------------------------
-- 时间 2021年9月28日
-- by jishenghua
-- 给序列号表增加仓库id
-- --------------------------------------------------------
alter table jsh_serial_number add depot_id bigint(20) DEFAULT NULL COMMENT '仓库id' after material_Id;

-- --------------------------------------------------------
-- 时间 2021年10月4日
-- by jishenghua
-- 给序列号表增加入库单号和出库单号字段，另外去掉单据id字段
-- 移除序列号菜单
-- --------------------------------------------------------
alter table jsh_serial_number add in_bill_no varchar(50) DEFAULT NULL COMMENT '入库单号' after updater;
alter table jsh_serial_number add out_bill_no varchar(50) DEFAULT NULL COMMENT '出库单号' after in_bill_no;
alter table jsh_serial_number drop column depot_head_id;
delete from jsh_function where number='010104';

-- --------------------------------------------------------
-- 时间 2021年10月12日
-- by jishenghua
-- 给租户表增加备注字段
-- --------------------------------------------------------
alter table jsh_tenant add remark varchar(500) DEFAULT NULL COMMENT '备注' after expire_time;

-- --------------------------------------------------------
-- 时间 2021年10月29日
-- by jishenghua
-- 给商品初始库存表增加最低库存数量、最高库存数量字段
-- 给商品表增加基础重量字段
-- 给商品表移除安全库存字段
-- --------------------------------------------------------
alter table jsh_material_initial_stock add low_safe_stock decimal(24,6) DEFAULT NULL COMMENT '最低库存数量' after number;
alter table jsh_material_initial_stock add high_safe_stock decimal(24,6) DEFAULT NULL COMMENT '最高库存数量' after low_safe_stock;
alter table jsh_material add weight decimal(24,6) DEFAULT NULL COMMENT '基础重量(kg)' after expiry_num;
alter table jsh_material drop column safety_stock;

-- --------------------------------------------------------
-- 时间 2021年11月5日
-- by jishenghua
-- 给用户/角色/模块关系表增加租户字段
-- 给用户/角色/模块关系表的租户字段赋值
-- --------------------------------------------------------
alter table jsh_user_business add tenant_id bigint(20) DEFAULT null COMMENT '租户id' after btn_str;
update jsh_user_business ub left join jsh_user u on ub.key_id=u.id set ub.tenant_id=u.tenant_id
where (ub.type='UserRole' or ub.type='UserDepot' or ub.type='UserCustomer') and u.tenant_id!=0;
update jsh_user_business ub left join jsh_role r on ub.key_id=r.id set ub.tenant_id=r.tenant_id
where (ub.type='RoleFunctions') and r.tenant_id is not null;