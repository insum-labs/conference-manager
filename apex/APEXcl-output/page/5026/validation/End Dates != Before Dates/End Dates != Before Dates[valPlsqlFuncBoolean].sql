declare
    retval boolean := true;
    l_blind_vote_end_date date;
    l_committee_vote_end_date date;
begin
    select blind_vote_end_date
      into l_blind_vote_end_date
      from ks_events
     where id = :P5026_EVENT_ID;

    select committee_vote_end_date
      into l_committee_vote_end_date
      from ks_events
     where id = :P5026_EVENT_ID;

    --Check if blind begin date comes AFTER this track's blind end date (if that's null, then check it against this event's blind end date)
    if    :P5026_BLIND_VOTE_BEGIN_DATE is not null
      and nvl(:P5026_BLIND_VOTE_END_DATE, l_blind_vote_end_date)  is not null 
      and nvl(to_date(:P5026_BLIND_VOTE_END_DATE, :DATE_FORMAT_MASK), l_blind_vote_end_date) < to_date(:P5026_BLIND_VOTE_BEGIN_DATE, :DATE_FORMAT_MASK)
    then
        retval := false;
    end if;


    --Do the same for committee begin date
    if    :P5026_COMMITTEE_VOTE_BEGIN_DAT is not null
      and nvl(:P5026_COMMITTEE_VOTE_END_DAT, l_committee_vote_end_date) is not null
      and nvl(to_date(:P5026_COMMITTEE_VOTE_END_DAT, :DATE_FORMAT_MASK), l_committee_vote_end_date) < to_date(:P5026_COMMITTEE_VOTE_BEGIN_DAT, :DATE_FORMAT_MASK)
    then
        retval := false;
    end if;


    return retval;

end;