create temporary table predb_tmp as select id, filename, title from predb WHERE created >= NOW() - INTERVAL 1 MONTH;
create temporary table releases_tmp as select id, name, searchname, categories_id, isrenamed from releases where predb_id = 0 AND postdate >= NOW() - INTERVAL 2 MONTH;
alter table predb_tmp add column vowels varchar(255) character set 'utf8' COLLATE 'utf8_unicode_ci';
create index ix_xi_ix3_xi on predb_tmp(filename);
update predb_tmp set vowels = regexp_replace(filename, '[AEIOUaeiou]', '');
create index ix_xi_ix_xi on predb_tmp(vowels);
create index xi_ix_2xi on releases_tmp(searchname);
create temporary table releases_predb as select releases_tmp.id as releases_id, predb_tmp.id as predb_id from releases_tmp inner join predb_tmp on releases_tmp.searchname = vowels and length(predb_tmp.vowels) > 8;
create index ix3 on predb_tmp(id, title);
create index ix4 on releases_predb(releases_id, predb_id);
update releases r inner join releases_predb ON r.id = releases_id inner join predb_tmp on releases_predb.predb_id = predb_tmp.id set r.predb_id = releases_predb.predb_id, r.searchname = predb_tmp.title;


update predb_tmp set vowels = regexp_replace(vowels, '\\..', '');
update predb_tmp set vowels = regexp_replace(vowels, '^.', '');
update releases_tmp set searchname = regexp_replace(searchname, '\\..', '');
update releases_tmp set searchname = regexp_replace(searchname, '^.', '');
create temporary table releases_predb2 as select releases_tmp.id as releases_id, predb_tmp.id as predb_id from releases_tmp inner join predb_tmp on releases_tmp.searchname = vowels and length(predb_tmp.vowels) > 8;
create index ix41 on releases_predb2(releases_id, predb_id);
update releases r inner join releases_predb2 ON r.id = releases_id inner join predb_tmp on releases_predb2.predb_id = predb_tmp.id set r.predb_id = releases_predb2.predb_id, r.searchname = predb_tmp.title;
