-- Reset the demo 
ALTER TABLE Patients ALTER COLUMN LastName DROP MASKED
ALTER TABLE Patients ALTER COLUMN MiddleName DROP MASKED
ALTER TABLE Patients ALTER COLUMN StreetAddress DROP MASKED
ALTER TABLE Patients ALTER COLUMN ZipCode DROP MASKED
go

-- Mask Last Name (Exposes only first Letter of Last Name)
ALTER TABLE Patients ALTER COLUMN LastName ADD MASKED WITH (FUNCTION = 'partial(1, "xxxx", 0)')

-- Mask middle initial, street address, and zip code (Fully Masked)
ALTER TABLE Patients ALTER COLUMN MiddleName ADD MASKED WITH (FUNCTION = 'default()')
ALTER TABLE Patients ALTER COLUMN StreetAddress ADD MASKED WITH (FUNCTION = 'default()')
ALTER TABLE Patients ALTER COLUMN ZipCode ADD MASKED WITH (FUNCTION = 'default()')
