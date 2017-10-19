UPDATE releases r
INNER JOIN 
    (SELECT predb.id AS predb_id,
         releases_id,
         title
    FROM predb
    INNER JOIN 
        (SELECT substring(name,
         1,
         locate('.', name, char_length(name) -6) - 1) AS base, releases_id
        FROM release_files
        WHERE
            1=1
            AND release_files.name != 'Front.jpg'
            AND release_files.name != 'Back.jpg'
        ) rf
            ON predb.filename = rf.base
        INNER JOIN releases
            ON releases.id = rf.releases_id
        WHERE proc_files = 0
                AND isrenamed = 0
                AND predb_id = 0) sq
        ON r.id = sq.releases_id SET r.predb_id = sq.predb_id,
         r.searchname = sq.title; 


UPDATE releases r
INNER JOIN 
    (SELECT predb.id AS predb_id,
         releases_id,
         title
    FROM predb
    INNER JOIN 
        (SELECT substring(name,
         1,
         locate('.', name, char_length(name) -6) - 1) AS base, releases_id
        FROM release_files
        WHERE
            1=1
            AND release_files.name != 'Front.jpg'
            AND release_files.name != 'Back.jpg'
        ) rf
            ON predb.filename = rf.base
        INNER JOIN releases
            ON releases.id = rf.releases_id
        WHERE 1=1
                AND categories_id >=1000 
                AND isrenamed = 0
                AND predb_id = 0) sq
        ON r.id = sq.releases_id SET r.predb_id = sq.predb_id,
         r.searchname = sq.title; 



UPDATE releases r
INNER JOIN 
    (SELECT predb.id AS predb_id,
         releases_id,
         title
    FROM predb
    INNER JOIN 
        (SELECT regexp_replace(name,
            '(\\.vol[0-9\+]+(\\+[0-9]+)?\\.par2|\\.par2|\\.part[0-9]+\\.rar|\\.rar|\\.nzb|\\.mp4|\\.avi|\\.r[0-9][0-9]|\\.nzb|.\mkv|\\.wmv|\\.0[0-9]][0-9]|\\.sfv)',
             '') AS base, releases_id
        FROM release_files
        WHERE
            1=1
            AND release_files.name != 'Front.jpg'
            AND release_files.name != 'Back.jpg'
        ) rf
            ON predb.filename = rf.base
        INNER JOIN releases
            ON releases.id = rf.releases_id
        WHERE categories_id >=1000 
                AND isrenamed = 0
                AND predb_id = 0) sq
        ON r.id = sq.releases_id SET r.predb_id = sq.predb_id,
         r.searchname = sq.title; 




UPDATE releases r
INNER JOIN 
    (SELECT rf.name AS textstring,
         rel.fromname,
         rel.categories_id,
         rel.name,
         rel.searchname,
         rel.groups_id,
         rf.releases_id AS fileid,
         rel.id AS releases_id
    FROM releases rel
    INNER JOIN 
        (SELECT *
        FROM release_files
        ORDER BY  releases_id, size desc) rf
            ON (rf.releases_id = rel.id)
        WHERE (rel.categories_id >= 1000)
                AND rel.predb_id = 0
                AND rel.name NOT LIKE 'Datestamped MP4'
                and rf.name != 'Front.jpg'
                AND rf.name != 'Back.jpg'
                AND (rel.name LIKE '%par2%'
                OR rel.name LIKE '%.rar%')
        GROUP BY  rel.id
        ORDER BY  rf.size desc) sq
        ON sq.releases_id = r.id AND LENGTH(sq.textstring) >= LENGTH(r.searchname) SET r.searchname = sq.textstring;

UPDATE releases r
INNER JOIN predb
    ON predb.filename = r.searchname SET r.predb_id = predb.id,
         r.searchname = predb.title
WHERE predb_id = 0
        AND categories_id >= 6000
        AND categories_id < 7000 ; 

UPDATE releases SET searchname = regexp_replace(name,
         '.*?(\[[0-9]+?/[0-9]+\])?.*?"(.+?)(\\.vol[0-9\+]+\\.par2|\\.par2|\\.part[0-9]+\\.rar|\\.rar|\\.nzb|\\.mp4|\\.avi|\\.r[0-9][0-9]|\\.nzb|\\.mkv|\\.sfv)?".*', '\\2')
WHERE predb_id = 0
        AND categories_id < 7000
        AND categories_id >= 6000
        AND isrenamed = 0
        AND name RLIKE '.*?".+?(XXX|nzb|par2|rar|mp4|avi|mkv|r[0-9][0-9]|\\.wmv|\\.0[0-9]][0-9])?".*'
        AND ( 
            TRIM(replace(replace(name, ' ' ,'.'), 'yEnc', '')) = TRIM(replace(replace(searchname, ' ' ,'.'), 'yEnc', ''))
            or char_length(regexp_replace(name, '.*?(\[[0-9]+?/[0-9]+\])?.*?"(.+?)(\\.vol[0-9\+]+\\.par2|\\.par2|\\.part[0-9]+\\.rar|\\.rar|\\.nzb|\\.mp4|\\.avi|\\.r[0-9][0-9]|\\.nzb|.\mkv|\\.wmv|\\.sfv|\\.0[0-9]][0-9])?".*', '\\2')) >= char_length(searchname)
            OR searchname rlike '.*(part|scene|disc|disk|sc[\\. #]*?[0-9]).+'
            OR searchname rlike '.+".*".*'
            ); 

UPDATE releases r
INNER JOIN predb
    ON predb.filename = r.searchname SET r.predb_id = predb.id,
         r.searchname = predb.title
WHERE predb_id = 0
        AND categories_id >= 6000
        AND categories_id < 7000 ; 


UPDATE releases SET searchname = regexp_replace(searchname,
         '(\\.vol[0-9\+]+\\.par2|\\.par2|\\.part[0-9]+\\.rar|\\.rar|\\.nzb|\\.mp4|\\.avi|\\.r[0-9][0-9]|\\.nzb|\\.mkv|\\.wmv|\\.0[0-9]][0-9]|\\.sfv)', '')
WHERE searchname rlike '.+(\\.vol[0-9\+]+\\.par2|\\.par2|\\.part[0-9]+\\.rar|\\.rar|\\.nzb|\\.mp4|\\.avi|\\.r[0-9][0-9]|\\.nzb|\\.mkv|\\.wmv|\\.0[0-9]][0-9]|\\.sfv)'
        AND predb_id = 0
        AND categories_id >= 6000
        AND categories_id < 7000; 

UPDATE releases r
INNER JOIN predb
    ON predb.filename = r.searchname SET r.predb_id = predb.id,
         r.searchname = predb.title
WHERE predb_id = 0
        AND categories_id >= 6000
        AND categories_id < 7000 ; 


update releases set searchname = regexp_replace(searchname, '(.+?)\\\\(.+)$' , '\\\2') where categories_id >= 6000 and categories_id < 7000 and predb_id = 0 and predb_id = 0 and searchname rlike 'VIDEOOT.+\\\\\.+';
update releases set searchname = regexp_replace(searchname, '(.+?)\\\\(.+)$' , '\\\1') where categories_id >= 6000 and categories_id < 7000 and predb_id = 0 and predb_id = 0 and searchname rlike '.+XXX.+\\\\\.+';
update releases set searchname = regexp_replace(searchname, 'u4a-(.+)', '\\\1') where searchname like 'u4a-%';


UPDATE releases r
INNER JOIN predb
    ON predb.filename = r.searchname SET r.predb_id = predb.id,
         r.searchname = predb.title
WHERE predb_id = 0
        AND categories_id >= 6000
        AND categories_id < 7000 ; 
 
update releases set searchname = replace(searchname, ' ', '.') where predb_id = 0 and (searchname rlike '.+XXX (720p|1080p|2160p|DVDRip).*'  or searchname rlike '.+(720p|1080p|2160p|DVDRip) XXX.*');

UPDATE releases r
INNER JOIN predb
    ON predb.filename = r.searchname SET r.predb_id = predb.id,
         r.searchname = predb.title
WHERE predb_id = 0
        AND categories_id >= 6000
        AND categories_id < 7000 ; 


update releases set searchname = regexp_replace(searchname, '^"(.+)"$', '\\1') where searchname rlike '^"(.+)"$';


UPDATE releases r
INNER JOIN predb
    ON predb.filename = r.searchname SET r.predb_id = predb.id,
         r.searchname = predb.title
WHERE predb_id = 0
        AND adddate > NOW() - INTERVAL 24 hour ; 

