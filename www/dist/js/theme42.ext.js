/*global apex, $v*/

/*!
 theme42.ext.js
 Copyright (c) 2012, 2017 Oracle and/or its affiliates. All rights reserved.
 */

/**
 * @fileOverview
 * The apex.theme42.ext namespace is used to store all theme42 extension functions.
 * We need to check its existence as this file may be part of future APEX release.
 **/

if ( apex.theme42 && !apex.theme42.ext ) {

    apex.theme42.ext = {};

    (function( $, ext ){
        "use strict";
        // Current Page ID.
        var pageId = $v( "pFlowStepId" );

        /**
         * Enables a text field item to search labels in another checkbox item.
         * Currently only checkbox label searching is supported.
         *
         * @param {Object} obj with the following option properties:
         *                 itemId:          The item to be searched.
         *                 searchFieldId:   Keyword text field that triggers the search.
         *
         * @example
         * apex.theme42.ext.filterItem({
         *   pItem:        "P1_COUNTRY",
         *   pSearchItem:  "P1_SEARCH"
         * });
         *
         * @function filterItem
         * @memberOf apex.theme42.ext
         **/

        ext.filterItem = function( obj ) {

            var CL_ACTIVE       = "js-filter-active",
                CL_MATCH        = "js-filter-match",
                TYPE_CB         = "CHECKBOX_GROUP",
                itemId          = obj.pItem,
                searchFieldId   = obj.pSearchItem,
                searchField$    = $( "#" + searchFieldId );

            searchField$.attr( "type", "search" );

            // Constructor to store lables to be searched, as well as their jQuery selectors
            var InitSearch = function( id ){
                var itemLabels = [],
                    itemType = apex.item( itemId ).item_type,
                    i;

                // Different item types may have different markup.
                // TODO: support more item types, e.g. radioboxes.
                var getLabel = function( obj$ ){
                    if ( itemType === TYPE_CB ) {
                        return obj$.next().text().toLowerCase();
                    }
                };

                var getWrapper = function( obj$ ){
                    if ( itemType === TYPE_CB ) {
                        return obj$.parent();
                    }
                };

                // Gather labels and their nodes
                $( "input[name=" + id + "]" ).each(function(){
                    var that$ = $( this );
                    itemLabels.push( {
                        node$: that$,
                        txt: getLabel( that$ )
                    });
                });

                this.search = function( key ) {
                    var i, current, wrapper$;

                    if ( key ) {
                        $( "#" + id ).addClass( CL_ACTIVE );
                        for ( i = 0; i < itemLabels.length; i++ ) {
                            current = itemLabels[i];
                            wrapper$ = getWrapper( current.node$ );
                            if ( current.txt.indexOf( key.toLowerCase() ) >= 0 ) {
                                wrapper$.addClass( CL_MATCH );
                            } else {
                                wrapper$.removeClass( CL_MATCH );
                            }
                        }
                    } else {
                        $( "#" + id ).removeClass( CL_ACTIVE );
                    }
                };
            };
            // supports multiple search on one page.
            var filter = new InitSearch( itemId );

            // search on page load, if search field already has value.
            filter.search( searchField$.val() );

            // search-as-you-type
            searchField$
                .on( "keydown", function( e ){
                    if ( e.which === 13 ) {
                        // Enter key won"t submit the page.
                        e.preventDefault();
                    } else if ( e.which === 27 ) {
                        // ESCAPE key won"t close dialog.
                        e.stopPropagation();
                        // Clears input for browsers that don"t support type="search"
                        $( this ).val( "" );
                    }
                })
                .on( "keyup", function( e ){
                    filter.search( $( this ).val() );
                });
        };

        /**
         * Filter Report Page is a report page that has a search / filter field(s), one or more reports with different
         * template, and a radio item to switch between the reports, with only one report displayed at a time.
         * This function handles the report refreshing when searching and toggling views.
         * Also please remember to set "Page Items to Submit" attribute in each report to use search item name.
         *
         * @param {Object} obj with the following properties:
         *                 pSearchItem:   The text field item to enter keywords.
         *                 pToggleItem:   The radio group item to switch region"s visibility
         *                 pRegions:      An object which has the mapping between returned values
         *                                of the above radio item and regions" static IDs.
         *                                See example below.
         *
         * @example:
         * apex.theme42.ext.filterReportPage({
         *     pSearchItem: "P1_SEARCH",
         *     pToggleItem: "P1_DISPLAY_AS",
         *     pRegions:    { CARDS:  "cards_region",
         *                    REPORT: "report_region" }
         * });
         *
         * @function filterReportPage
         * @memberOf apex.theme42.ext
         **/

        ext.filterReportPage = function ( obj ) {
            var regions         = obj.pRegions,
                displayAsId     = obj.pToggleItem,
                displayAs$      = $( "#" + displayAsId ),
                searchField$    = $( "#" + obj.pSearchItem ),
                types           = Object.keys( regions),
                delay;

            var refreshReport = function() {
                var type = $v( displayAsId ),
                    key  =  searchField$.val(),
                    regionId,
                    region$,
                    i;

                for ( i = 0; i < types.length; i++ ) {
                    regionId = regions[ types[ i ] ];
                    region$  = $( "#" + regionId);
                    if ( type === types[ i ] ) {
                        region$.show();
                        // optimize refresh by comparing stored keyword
                        if ( region$.data( "key" ) !== key ) {
                            region$.trigger( "apexrefresh" ).data( "key", key );
                        }
                    } else {
                        region$.hide();
                    }
                }
            };

            // events
            searchField$
                .on( "keydown", function ( e ) {
                    if (e.which === 13) {
                        // prevent ENTER key to submit page
                        e.preventDefault();
                    }
                })
                .on( "input", function () {
                    clearTimeout( delay );
                    delay = setTimeout(refreshReport, 250);
                });

            displayAs$.change( refreshReport );

            // init
            refreshReport();
        };

        /**
         * Master Details Page
         * TODO: documentation and change parameter to obj.
         **/

        ext.masterDetailPage = {};

        (function( m ){

            // The name of the Primary Key item. e.g. "P8_ID".
            // it is set on page load using masterDetail.initializePage()
            var primaryKeyItem,
            // The hidden item that holds the filter count value.
                filterCountItem  = "P" + pageId + "_FILTER_COUNT",
            // URL of buttons to open modal dialog.
                buttons = [],
                LINK_CLASS = "js-master-row";

            // Select regions to be refreshed or show/hide.
            // Details region reports should have ".js-detail-rds" class
            // in order to be dynamically refreshed.
            var masterDetailRegions$  = $( ".js-master-region, .js-detail-rds, .js-detail-region" ),
                noRowSelectedRegion$  = $( ".no-record-selected" ),
                bodyContentContainer$ = $( ".t-Body-contentInner" );

            var hideRecord = function() {
                masterDetailRegions$.hide();
                noRowSelectedRegion$.show();
                bodyContentContainer$.addClass( "center-regions" );
            };

            var showRecord = function() {
                masterDetailRegions$.show();
                noRowSelectedRegion$.hide();
                bodyContentContainer$.removeClass( "center-regions" );
            };

            var scrollToRecord = function( id, requireRefresh ) {
                var ml$ = $( "." + LINK_CLASS );
                if ( ml$[0] ) {
                    var currentRow$ = ml$.filter( "[data-id=\"" + id + "\"]").parent();
                    if ( requireRefresh ) {
                        loadRecords( currentRow$.find( "a." + LINK_CLASS ) );
                    }

                    $( ".search-results" ).animate(
                        {
                            scrollTop: currentRow$.position().top - $( ".search-region" ).outerHeight()
                        }, 500 );

                    currentRow$.addClass( "is-active" ).focus();
                }
            };

            var loadRecords = function( obj ){
                var recordContainers$ = $( "." + LINK_CLASS ).parent(),
                    triggeringElem$ = $( obj );

                $.ajax({
                    url: triggeringElem$.data( "checksum" )
                }).done( refreshReports );

                recordContainers$.removeClass( "is-active" );
                triggeringElem$.parent().addClass( "is-active" );
            };

            var refreshReports = function(){
                // refresh all details reports
                masterDetailRegions$.trigger( "apexrefresh" );
                // refresh the report used to generate buttons
                $( ".js-links-region" ).trigger( "apexrefresh" );
                showRecord();
            };

            var updateFilterBadge = function(){
                var filterBadge$,
                    count = $v( filterCountItem );
                // Append filter count markup to the Apply Filters button
                $( "#apply_filters_btn .t-Button-label" ).append( "<span id=\"filter_count\"></span>" );
                filterBadge$  = $( "#filter_count" );
                // Update count
                if ( count > 0 ) {
                    filterBadge$.text( count );
                } else {
                    filterBadge$.text("");
                }
            };

            var buildButtons = function(){
                var bLen = buttons.length,
                    aButton,
                    i;
                // populate the array with button IDs from the hidden report called "Edit Links"
                $( "#links_region .js-button-url" ).each(function(){
                    buttons.push( $( this ).data( "button-id" ) );
                });
                // update the "onclick" attribute existing buttons to open correct modal dialogs
                // for the record id selected.
                for ( i = 0; i < bLen; i++ ) {
                    aButton = buttons[i];
                    $( "#" + aButton )
                        .attr( "onclick", $( "[data-button-id=\"" + aButton + "\"]" )
                        .attr( "href" ) );
                }
            };

            var initializePage = function( keyItem ){
                primaryKeyItem = keyItem;
                // highlight and scroll to the record if you are coming from another report
                var currentID = $v( primaryKeyItem );
                if ( currentID !== "" ) {
                    $( window ).on( "theme42ready", function() {
                        scrollToRecord( currentID );
                        showRecord();
                    });
                } else {
                    hideRecord();
                }
                // click event on row links
                $( "body" ).on("click", "." + LINK_CLASS, function( e ) {
                    loadRecords( this );
                });
                // prepare the button URLs to open modal dialogs
                $( "#links_region .js-button-url" ).each(function( e ){
                    buttons.push( $( this ).data( "button-id" ) );
                });
            };
            // public methods to be used in Dynamic Actions.
            m.initializePage        = initializePage;
            m.hideRecord            = hideRecord;
            m.showRecord            = showRecord;
            m.scrollToRecord        = scrollToRecord;
            m.refreshReports        = refreshReports;
            m.buildButtons          = buildButtons;
            m.updateFilterBadge     = updateFilterBadge;

        })( ext.masterDetailPage );

    })( apex.jQuery, apex.theme42.ext );

}
//# sourceMappingURL=theme42.ext.js.map
