RESTORE DATABASE EduTrack_DB
FROM DISK = '/var/opt/mssql/data/backup.bak'
WITH MOVE 'EduTrack_DB' TO '/var/opt/mssql/data/EduTrack_DB.mdf',
     MOVE 'EduTrack_DB_log' TO '/var/opt/mssql/data/EduTrack_DB_log.ldf',
     REPLACE;