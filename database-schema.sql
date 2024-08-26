-- SQLite database schema for app
-- List is separated by comma
CREATE TABLE Place (
    id INTEGER AUTOINCREMENT PRIMARY KEY,
    name TEXT NOT NULL,
    lat REAL NOT NULL,
    lng REAL NOT NULL
    precision INTEGER DEFAULT 50 -- in meters
);
CREATE TABLE Task (
    id INTEGER AUTOINCREMENT PRIMARY KEY,
    completed BOOLEAN NOT NULL DEFAULT 0,
    title TEXT NOT NULL,
    attachments TEXT NOT NULL DEFAULT '', -- list of file paths
    time TEXT NOT NULL DEFAULT '', -- time in 24h format (e.g. 1200 = 12:00) or empty string if not set
    date TEXT NOT NULL, -- date in YYYYMMDD format (e.g. 20220101 = 2022-01-01)
    is_deadline BOOLEAN NOT NULL DEFAULT 0, 
    repeat_type TEXT CHECK (repeat_type IN (NULL, 'DAILY', 'WEEKLY', 'MONTHLY_DAY_WEEK', 'MONTHLY_DAY', 'YEARLY')), -- NULL = no repeat ...
    repeat_interval INTEGER, -- every N days, weeks, months, or years
    repeat_days TEXT -- list of days of week for WEEKLY repeat (monday=0, tuesday=1, ...)
    -- or number of week in month and list of days of week speparated by comma for MONTHLY_DAY_WEEK repeat
    -- or list of days of month for MONTHLY_DAY
    end_type TEXT CHECK (end_type IN (NULL, 'DATE', 'TIMES')), -- NULL = no end ...
    end_on TEXT -- date in YYYYMMDD format (e.g. 20220101 = 2022-01-01) or number of times
    exclude TEXT -- list of dates in YYYYMMDD format (e.g. 20220101 = 2022-01-01)
    place_id INTEGER REFERENCES Place(id)
);