begin
    if    
         (to_date(:P5025_END_DATE, :DATE_FORMAT_MASK)               >= to_date(:P5025_BEGIN_DATE, :DATE_FORMAT_MASK)
       or :P5025_END_DATE is null
         )
      and (to_date(:P5025_BLIND_VOTE_END_DATE, :DATE_FORMAT_MASK)    >= to_date(:P5025_BLIND_VOTE_BEGIN_DATE, :DATE_FORMAT_MASK)
       or (:P5025_BLIND_VOTE_END_DATE is null or  :P5025_BLIND_VOTE_BEGIN_DATE is null)
          )
      and (to_date(:P5025_COMMITTEE_VOTE_END_DT, :DATE_FORMAT_MASK)   >= to_date(:P5025_COMMITTEE_VOTE_BEGIN_DT, :DATE_FORMAT_MASK)
       or (:P5025_COMMITTEE_VOTE_END_DT is null or :P5025_COMMITTEE_VOTE_BEGIN_DT is null)
          )
    then
        return true;
    else
        return false;
    end if;

end;