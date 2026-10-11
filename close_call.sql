-- Close a call by ID
UPDATE calls 
SET status = 'closed' 
WHERE id = 'YOUR_CALL_ID_HERE';

-- Or close multiple calls
UPDATE calls 
SET status = 'closed' 
WHERE id IN ('CALL_ID_1', 'CALL_ID_2', 'CALL_ID_3');