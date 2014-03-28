$(document).ready(function() {

	$('#marginalia').wrap('<div id="marginalia_wrapper"></div>');

    // move sub navigation into parent list elements 
    $('#marginalia > li.active').each(function() {
        var $SubElem = $(this).next('li');
        $(this).append($SubElem.html());
        $SubElem.remove();
    });

    $('#search').appendTo($('#marginalia_wrapper'));

    // Make table of contents collapsable
    $('.toc p b a').live('click', function() {
        $(this).parent().parent().next('dl').slideToggle('fast', function() {
            $(this).parent().toggleClass('closed');
        });
        return false;
    });
    
    // Add anchor link to scroll to the top of the page
    $('body').append('<a href="#top" id="totop">^ <span>Use Elevator</span></a>');
    $('#totop').live('click', function() {
        $('html,body').animate({scrollTop: '0px'}, 1000);
        return false;
    });
    
    $('.toc p b').append('<a href="">Hide</a>');
    $('.section .toc').prepend('<p><b>Article navigation <a href="">Hide</a></b></p>');
    
});
