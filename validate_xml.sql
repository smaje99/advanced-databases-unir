CREATE EXTENSION plpython3u;

CREATE OR REPLACE FUNCTION validate_xml_against_xsd(xml_content TEXT, xsd_content TEXT) RETURNS BOOLEAN AS $$
import lxml.etree as ET

try:
    # Parse the XML and XSD content
    xml_doc = ET.fromstring(xml_content)
    xsd_doc = ET.fromstring(xsd_content)
    xmlschema = ET.XMLSchema(xsd_doc)

    # Validate the XML
    xmlschema.assertValid(xml_doc)
    return True
except ET.DocumentInvalid as e:
    plpy.error(str(e))
    return False
$$ LANGUAGE plpython3u;


CREATE OR REPLACE FUNCTION insert_employee_from_xml(xml_data TEXT, xsd_data TEXT) RETURNS VOID AS $$
DECLARE
    fname TEXT;
    lname TEXT;
    email TEXT;
    phone TEXT;
    hire_date DATE;
    job_id TEXT;
    salary NUMERIC;
    commission NUMERIC;
    manager_id INTEGER;
    dept_id INTEGER;
    is_valid BOOLEAN;
BEGIN
    -- Validar el XML contra el XSD
    is_valid := validate_xml_against_xsd(xml_data, xsd_data);

    IF is_valid THEN
        -- Extraer datos del XML
        SELECT (xpath('/employee/firstName/text()', xml_data::xml))[1]::TEXT INTO fname;
        SELECT (xpath('/employee/lastName/text()', xml_data::xml))[1]::TEXT INTO lname;
        SELECT (xpath('/employee/email/text()', xml_data::xml))[1]::TEXT INTO email;
        SELECT (xpath('/employee/phoneNumber/text()', xml_data::xml))[1]::TEXT INTO phone;
        SELECT (xpath('/employee/hireDate/text()', xml_data::xml))[1]::TEXT::DATE INTO hire_date;
        SELECT (xpath('/employee/jobId/text()', xml_data::xml))[1]::TEXT INTO job_id;
        SELECT (xpath('/employee/salary/text()', xml_data::xml))[1]::TEXT::NUMERIC INTO salary;
        SELECT (xpath('/employee/commissionPct/text()', xml_data::xml))[1]::TEXT::NUMERIC INTO commission;
        SELECT (xpath('/employee/managerId/text()', xml_data::xml))[1]::TEXT::INTEGER INTO manager_id;
        SELECT (xpath('/employee/departmentId/text()', xml_data::xml))[1]::TEXT::INTEGER INTO dept_id;

        -- Insertar datos en la tabla employees
        INSERT INTO employees (
            first_name, last_name, email, phone_number,
            hire_date, job_id, salary, commission_pct, manager_id, department_id
        ) VALUES (
            fname, lname, email, phone, hire_date, job_id, salary,
            commission, manager_id, dept_id
        );
    ELSE
        RAISE EXCEPTION 'XML validation failed';
    END IF;
END;
$$ LANGUAGE plpgsql;


DO $$
BEGIN
    PERFORM insert_employee_from_xml(
        '<?xml version="1.0"?>
        <employee>
            <firstName>John</firstName>
            <lastName>Doe</lastName>
            <email>johndoe@example.com</email>
            <phoneNumber>555-1234</phoneNumber>
            <hireDate>2023-06-01</hireDate>
            <jobId>AD_PRES</jobId>
            <salary>60000.00</salary>
            <commissionPct>0.10</commissionPct>
            <managerId>201</managerId>
            <departmentId>10</departmentId>
        </employee>',
        '<?xml version="1.0"?>
        <xs:schema xmlns:xs="http://www.w3.org/2001/XMLSchema">
            <xs:element name="employee">
                <xs:complexType>
                    <xs:sequence>
                        <xs:element name="firstName" type="xs:string"/>
                        <xs:element name="lastName" type="xs:string"/>
                        <xs:element name="email" type="xs:string"/>
                        <xs:element name="phoneNumber" type="xs:string"/>
                        <xs:element name="hireDate" type="xs:date"/>
                        <xs:element name="jobId" type="xs:string"/>
                        <xs:element name="salary" type="xs:decimal"/>
                        <xs:element name="commissionPct" type="xs:decimal"/>
                        <xs:element name="managerId" type="xs:integer"/>
                        <xs:element name="departmentId" type="xs:integer"/>
                    </xs:sequence>
                </xs:complexType>
            </xs:element>
        </xs:schema>'
    );
END $$;
