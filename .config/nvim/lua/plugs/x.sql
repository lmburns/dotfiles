SELECT
  *
FROM
  tag
WHERE
  id NOT IN (
    SELECT
      DISTINCT(tag_id)
    FROM
      file_tag
  );
