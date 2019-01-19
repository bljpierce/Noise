#############################################################################
#                                                                           #
#                                Noise.pm                                   #
#                                                                           #
#     A collection of noise unit generators implemented in pure Perl.       #
#                                                                           #
#                    Copyright (c) 2019, Barry Pierce                       #
#                                                                           #
#############################################################################                                   
package Noise;
use strict;
use warnings;


use Carp 'croak';
use base 'Exporter';


our @EXPORT_OK = qw(
    make_white_noise 
    make_sah
    make_isah
);

our %EXPORT_TAGS = ( all => \@EXPORT_OK );

# white noise factory function
sub make_white_noise {
    croak 'missing $vec_siz argument' if @_ < 1;
    my ($vec_siz) = @_;
    
    if ($vec_siz < 1) {
        croak '$vec_siz must be a positive integer value';
    }
    
    # generate random numbers between -$max_amp & $max_amp
    return sub {
        my ($max_amp) = @_;
        
        my @vec;
        
        for (1 .. $vec_siz) {
            push @vec, (rand(2) - 1) * $max_amp;
        }
        
        return wantarray ? @vec : $vec[0];
    }
}

# sample and hold factory function
sub make_sah {
    my ($samp_rate) = @_;
    
    $samp_rate //= 44100;
    
    if ($samp_rate < 0) {
        croak '$samp_rate must be a positive integer value';
    }
    
    my $phase  = 0;
    my $inv_sr = 1 / $samp_rate;
    my $n      = rand(1); 
    my $v;
    
    return sub {
        my ($freq, $max_amp) = @_;
        $v      = $n;
        $phase += $freq * $inv_sr;
        if ($phase >= 1) {
            $phase -= 1;
            $n      = rand(1);
        }
        
        return $v * $max_amp;
    }
}

# interpolated sample and hold factory function
sub make_isah{
    my ($samp_rate) = @_;
    
    $samp_rate //= 44100;
    
    if ($samp_rate < 0) {
        croak '$samp_rate must be a positive integer value';
    }
    
    my $inv_sr = 1 / $samp_rate;
    my $n1     = rand(1);
    my $n2     = rand(1);
    my $mag    = $n2 - $n1;
    my $phase  = 0;
    my $v;
    
    return sub {
        my ($freq, $max_amp) = @_;
        
        $v      = $n1 + ($phase * $mag);
        $phase += $freq * $inv_sr;
        
        if ($phase >= 1) {
            $phase -= 1;
            $n1     = $n2;
            $n2     = rand(1);
            $mag    = $n2 - $n1; 
        }
        
        return $v * $max_amp;
    }
}


1;
