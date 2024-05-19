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
            <salary>Sixty thousand</salary>
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
