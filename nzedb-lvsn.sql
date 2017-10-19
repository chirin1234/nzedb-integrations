DROP FUNCTION IF EXISTS levenshtein_limit_n;

DELIMITER $$
CREATE FUNCTION levenshtein_limit_n( s1 VARCHAR(255), s2 VARCHAR(255), n INT) 
  RETURNS INT 
  DETERMINISTIC 
  BEGIN 
    DECLARE s1_len, s2_len, i, j, c, c_temp, cost, c_min INT; 
    DECLARE s1_char CHAR; 
    -- max strlen=255 
    DECLARE cv0, cv1 VARBINARY(256); 
    SET s1_len = CHAR_LENGTH(s1), s2_len = CHAR_LENGTH(s2), cv1 = 0x00, j = 1, i = 1, c = 0, c_min = 0; 
    IF s1 = s2 THEN 
      RETURN 0; 
    ELSEIF s1_len = 0 THEN 
      RETURN s2_len; 
    ELSEIF s2_len = 0 THEN 
      RETURN s1_len; 
    ELSE 
      WHILE j <= s2_len DO 
        SET cv1 = CONCAT(cv1, UNHEX(HEX(j))), j = j + 1; 
      END WHILE; 
      WHILE i <= s1_len and c_min < n DO -- if actual levenshtein dist >= limit, don't bother computing it
        SET s1_char = SUBSTRING(s1, i, 1), c = i, c_min = i, cv0 = UNHEX(HEX(i)), j = 1; 
        WHILE j <= s2_len DO 
          SET c = c + 1; 
          IF s1_char = SUBSTRING(s2, j, 1) THEN  
            SET cost = 0; ELSE SET cost = 1; 
          END IF; 
          SET c_temp = CONV(HEX(SUBSTRING(cv1, j, 1)), 16, 10) + cost; 
          IF c > c_temp THEN SET c = c_temp; END IF; 
            SET c_temp = CONV(HEX(SUBSTRING(cv1, j+1, 1)), 16, 10) + 1; 
            IF c > c_temp THEN  
              SET c = c_temp;  
            END IF; 
            SET cv0 = CONCAT(cv0, UNHEX(HEX(c))), j = j + 1;
            IF c < c_min THEN
              SET c_min = c;
            END IF; 
        END WHILE; 
        SET cv1 = cv0, i = i + 1; 
      END WHILE; 
    END IF;
    IF i <= s1_len THEN -- we didn't finish, limit exceeded    
      SET c = c_min; -- actual distance is >= c_min (i.e., the smallest value in the last computed row of the matrix) 
    END IF;
    RETURN c;
  END$$

  DELIMITER ; $$



create temporary table predb_tmp as select id, filename, title from predb WHERE created >= NOW() - INTERVAL 36 HOUR AND category LIKE 'XXX%' AND filename !='' and title not like '%IMAGESET%' AND filename not like '% %';
create temporary table releases_tmp as select id, name, searchname, categories_id, isrenamed from releases where predb_id = 0 AND postdate >= NOW() - INTERVAL 2 DAY AND categories_id >= 6000 and categories_id < 7000
    AND searchname NOT RLIKE '[aeiou]';
alter table predb_tmp add column vowels varchar(255) character set 'utf8' COLLATE 'utf8_unicode_ci';
create index ix_xi_ix3_xi on predb_tmp(filename);
update predb_tmp set vowels = regexp_replace(filename, '[AEIOUaeiou]', '');
create index ix_xi_ix_xi on predb_tmp(vowels);
create index xi_ix_2xi on releases_tmp(searchname);
create temporary table tmp_lvsn as select releases_tmp.id as releases_id, predb_tmp.id as predb_id, filename, searchname, title, name, levenshtein_limit_n(vowels, searchname, 20) as distance from releases_tmp, predb_tmp where levenshtein_limit_n(vowels, searchname, 20) <= 5;
create index iiiiii on tmp_lvsn(releases_id);
update releases r inner join tmp_lvsn on r.id = releases_id set r.searchname = title, r.predb_id = tmp_lvsn.predb_id;
