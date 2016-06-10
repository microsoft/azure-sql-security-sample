ECHO Executing postdeploy.cmd

ECHO Running sql scripts...
rem FYI the following requires the connection string to end in ; 
SET _conn=%SQLAZURECONNSTR_DefaultConnection%
SET _conn=%_conn: =%                                        &:: remove whitespace
SET _conn="%_conn:;=";"%"                                   &:: add quotes around each piece
FOR %%a IN (%_conn%) DO @FOR /F %%b IN (%%a) DO SET _%%b    &:: set pieces as variables
SET _conn=


set retryNumber=0
set step=bacpac

:STEPbacpac
ECHO Importing .bacpac
sqlcmd -S %_DataSource% -d %_InitialCatalog% -U %APPSETTING_administratorLogin% -P %APPSETTING_administratorLoginPassword% -i .\sql\Clinic.sql

IF ERRORLEVEL 1 GOTO :RETRY
ECHO Step %step% succeeded! 
set retryNumber=0

:STEPsqlcmd
set step=sqlcmd
ECHO Setting users
sqlcmd -S %_DataSource% -d %_InitialCatalog% -U %APPSETTING_administratorLogin% -P %APPSETTING_administratorLoginPassword% -Q "CREATE USER %APPSETTING_applicationLogin% WITH PASSWORD = '%APPSETTING_applicationLoginPassword%'"
sqlcmd -S %_DataSource% -d %_InitialCatalog% -U %APPSETTING_administratorLogin% -P %APPSETTING_administratorLoginPassword% -Q "ALTER ROLE db_datareader ADD MEMBER %APPSETTING_applicationLogin%"
sqlcmd -S %_DataSource% -d %_InitialCatalog% -U %APPSETTING_administratorLogin% -P %APPSETTING_administratorLoginPassword% -Q "ALTER ROLE db_datawriter ADD MEMBER %APPSETTING_applicationLogin%"
sqlcmd -S %_DataSource% -d %_InitialCatalog% -U %APPSETTING_administratorLogin% -P %APPSETTING_administratorLoginPassword% -Q "GRANT VIEW ANY COLUMN MASTER KEY DEFINITION To Public"
sqlcmd -S %_DataSource% -d %_InitialCatalog% -U %APPSETTING_administratorLogin% -P %APPSETTING_administratorLoginPassword% -Q "GRANT VIEW ANY COLUMN ENCRYPTION KEY DEFINITION To Public"

IF ERRORLEVEL 1 GOTO :RETRY
ECHO Step %step% succeeded!
GOTO :FIN

:RETRY backpac 
@echo (%date% %time%) Retrying Step%step%
@echo %_DataSource% %_InitialCatalog% %APPSETTING_administratorLogin%
set /a nseconds=10*%retryNumber%
Sleep %nseconds%
set /a retryNumber=%retryNumber%+1
IF %retryNumber% LSS 3 (GOTO :STEP%step%)
IF %retryNumber% EQU 3 (GOTO :ERR)

:ERR
@echo (%date% %time%) Script failed in step%step%
EXIT /B 1

:FIN
ECHO Finished executing postdeploy.cmd
EXIT