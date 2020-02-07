begin
    if    :P5026_BLIND_VOTE_BEGIN_DATE is null 
      and :P5026_BLIND_VOTE_END_DATE is not null
    then
        return false;
    end if;

    if    :P5026_COMMITTEE_VOTE_BEGIN_DAT is null 
      and :P5026_COMMITTEE_VOTE_END_DAT is not null
    then
        return false;
    end if;
    
    return true;

end;