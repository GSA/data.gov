/* To clear 2 harvest sources at once, using DB queries.
   The harvest source ID's need to be found beforehand, you can search using the title or url like
   "SELECT * FROM harvest_source WHERE url LIKE '%data.doi.gov%' AND title LIKE '%DOI%' AND url NOT LIKE '%WAF%';"
   These ID's need to be added/replaced in multiple places, noted by comments.
   If this continues to fail, there are probably some datasets in the to_delete state that cannot be removed. Simply run
       "UPDATE package SET state = 'to_remove' WHERE state = 'to_delete'"
   Then run the sql below, then reset the database to where it was before:
       "UPDATE package SET state = 'to_delete' WHERE state = 'to_remove'"
*/

begin;
    /* Replace ID's below */
    update package set state = 'to_delete' where id in (
      select package_id from harvest_object where harvest_source_id = '34ce571b-cb98-4e0b-979f-30f9ecc452c5' 
      OR harvest_source_id = '1f3ebea5-58d2-4aaa-85a0-e7ebda3074e7' 
      OR harvest_source_id = 'd8ef5c4f-b0fe-4338-afe9-089c029ea378'
    );
    delete from resource_view where resource_id in (
      select id from resource where package_id in (
        select id from package where state = 'to_delete' 
      )
    );
    delete from resource_revision where package_id in (select id from package where state = 'to_delete' );
    delete from resource where package_id in (select id from package where state = 'to_delete' );
    
    /* Replace ID's below */
    delete from harvest_object_error where harvest_object_id in (
      select id from harvest_object where harvest_source_id = '34ce571b-cb98-4e0b-979f-30f9ecc452c5' 
      OR harvest_source_id = '1f3ebea5-58d2-4aaa-85a0-e7ebda3074e7'
      OR harvest_source_id = 'd8ef5c4f-b0fe-4338-afe9-089c029ea378'
    );
    /* Replace ID's below */
    delete from harvest_object_extra where harvest_object_id in (
      select id from harvest_object where harvest_source_id = '34ce571b-cb98-4e0b-979f-30f9ecc452c5' 
      OR harvest_source_id = '1f3ebea5-58d2-4aaa-85a0-e7ebda3074e7'
      OR harvest_source_id = 'd8ef5c4f-b0fe-4338-afe9-089c029ea378'
    );
    /* Replace ID's below */
    delete from harvest_object where harvest_source_id = '34ce571b-cb98-4e0b-979f-30f9ecc452c5' 
    OR harvest_source_id = '1f3ebea5-58d2-4aaa-85a0-e7ebda3074e7'
    OR harvest_source_id = 'd8ef5c4f-b0fe-4338-afe9-089c029ea378';
    /* Replace ID's below */
    delete from harvest_gather_error where harvest_job_id in (
      select id from harvest_job where source_id = '34ce571b-cb98-4e0b-979f-30f9ecc452c5' 
      OR source_id = '1f3ebea5-58d2-4aaa-85a0-e7ebda3074e7'
      OR source_id = 'd8ef5c4f-b0fe-4338-afe9-089c029ea378'
    );
    /* Replace ID's below */
    delete from harvest_job where source_id = '34ce571b-cb98-4e0b-979f-30f9ecc452c5' 
    OR source_id = '1f3ebea5-58d2-4aaa-85a0-e7ebda3074e7'
    OR source_id = 'd8ef5c4f-b0fe-4338-afe9-089c029ea378';
    delete from package_role where package_id in (select id from package where state = 'to_delete' );

    DELETE FROM user_object_role
    USING user_object_role u
    LEFT JOIN package_role p
    ON u.id = p.user_object_role_id
    WHERE
    p.user_object_role_id IS NULL
    AND u.context = 'Package'
    AND user_object_role.id = u.id
    ;

    delete from package_tag_revision where package_id in (select id from package where state = 'to_delete');
    delete from member_revision where table_id in (select id from package where state = 'to_delete');
    delete from package_extra_revision where package_id in (select id from package where state = 'to_delete');
    delete from package_revision where id in (select id from package where state = 'to_delete');
    delete from package_tag where package_id in (select id from package where state = 'to_delete');
    delete from package_extra where package_id in (select id from package where state = 'to_delete');
    delete from member where table_id in (select id from package where state = 'to_delete');
    delete from related_dataset where dataset_id in (select id from package where state = 'to_delete');
    delete from related where id in ('');
    delete from package where state = 'to_delete';
commit;
