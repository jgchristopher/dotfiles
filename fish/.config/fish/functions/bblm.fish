function bblm --description "Big Bang Local Migration - show data types and row counts"
    duckdb -c "
SELECT
    CASE
        WHEN filename ILIKE '%Agencies%' THEN 'Agency'
        WHEN filename ILIKE '%Producer%' THEN 'Producer'
        WHEN filename ILIKE '%insured%' THEN 'Insured'
        WHEN filename ILIKE '%Mortgagee%' THEN 'Mortgagee'
        WHEN filename ILIKE '%AdditionalInsured%' THEN 'Additional Insured'
        WHEN filename ILIKE '%Address%' THEN 'Address'
        WHEN filename ILIKE '%Policies_Dwelling%' THEN 'Policy (DP3)'
        WHEN filename ILIKE '%Policies_HomeOwners%' THEN 'Policy (HO)'
        WHEN filename ILIKE '%Account_History%' THEN 'Account History'
        WHEN filename ILIKE '%CommissionAccounting%' THEN 'Commission Accounting'
        WHEN filename ILIKE '%CommissionPayments%' THEN 'Commission Payment'
        WHEN filename ILIKE '%Payments%' THEN 'Payment'
        WHEN filename ILIKE '%Notes%' THEN 'Note'
        WHEN filename ILIKE '%PolicyAtach%' THEN 'Policy Attachment'
        WHEN filename ILIKE '%credit_reports%' THEN 'Credit Report'
        WHEN filename ILIKE '%dates_to_remember%' THEN 'Date to Remember'
        ELSE replace(replace(filename, 'data/csvs/', ''), '.csv', '')
    END AS data_type,
    count(*) AS row_count
FROM read_csv_auto('data/csvs/*.csv', filename=true, union_by_name=true)
GROUP BY data_type
ORDER BY row_count DESC;
"
end
