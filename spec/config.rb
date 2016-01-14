# Modify these as needed

HTTP_SUCCESS = 200
HTTP_UNPROCESSABLE = 422
BASE_URL = 'http://localhost:3000'
RESET_DB_COMMAND = 'pg_restore --clean -d glexport_development glexport_development.psql.dump'
# RESET_DB_COMMAND = 'mysql -u root glexport_development < glexport_development.mysql.dump'

YALMART_ID = 2
DOSTCO_ID = 3