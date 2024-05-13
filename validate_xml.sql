CREATE EXTENSION plpython3u;

CREATE OR REPLACE FUNCTION validate_xml_against_xsd(xml_content TEXT, xsd_content TEXT) RETURNS BOOLEAN AS $$
import lxml.etree as ET

def validate_xml_against_xsd(xml_content, xsd_content):
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
        SELECT
            xpath('/employee/firstName/text()', xml_data::xml)::TEXT INTO fname,
            xpath('/employee/lastName/text()', xml_data::xml)::TEXT INTO lname,
            xpath('/employee/email/text()', xml_data::xml)::TEXT INTO email,
            xpath('/employee/phoneNumber/text()', xml_data::xml)::TEXT INTO phone,
            xpath('/employee/hireDate/text()', xml_data::xml)::TEXT::DATE INTO hire_date,
            xpath('/employee/jobId/text()', xml_data::xml)::TEXT INTO job_id,
            xpath('/employee/salary/text()', xml_data::xml)::TEXT::NUMERIC INTO salary,
            xpath('/employee/commissionPct/text()', xml_data::xml)::TEXT::NUMERIC INTO commission,
            xpath('/employee/managerId/text()', xml_data::xml)::TEXT::INTEGER INTO manager_id,
            xpath('/employee/departmentId/text()', xml_data::xml)::TEXT::INTEGER INTO dept_id;

        -- Insertar datos en la tabla employees
        INSERT INTO hr.employees (
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
            <jobId>DEV</jobId>
            <salary>60000.00</salary>
            <commissionPct>0.10</commissionPct>
            <managerId>2</managerId>
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
