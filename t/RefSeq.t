# -*-Perl-*- Test Harness script for Bioperl
# $Id$

use strict;

BEGIN {
    use Bio::Root::Test;

    test_begin(-tests => 12,
               -requires_modules => [qw(IO::String
                                        LWP::UserAgent
                                        HTTP::Request::Common)]);
    use_ok('Bio::DB::RefSeq');
    use_ok('Bio::DB::GenBank');
}

my $verbose = test_debug() || -1;

my ($db,$seq);
# get a single seq

$seq = undef;

#test redirection from GenBank
ok $db = Bio::DB::GenBank->new('-verbose'=> $verbose, -redirect_refseq => 1);

eval {
    $seq = $db->get_Seq_by_acc('NT_006732');
};
ok $@;

SKIP: {
    test_skip(-tests => 8, -requires_networking => 1);

    eval {
        ok($seq = $db->get_Seq_by_acc('NM_006732'));
        is($seq->length, 3776);
    };
    skip "Warning: Couldn't connect to RefSeq with Bio::DB::RefSeq.pm!", 8 if $@;

    eval {
        ok defined($db = Bio::DB::RefSeq->new(-verbose=>$verbose));
        ok(defined($seq = $db->get_Seq_by_acc('NM_006732')));
        is( $seq->length, 3776);
        ok defined ($db->request_format('fasta'));
        ok(defined($seq = $db->get_Seq_by_acc('NM_006732')));
        is( $seq->length, 3776);
    };
    skip "Warning: Couldn't connect to RefSeq with Bio::DB::RefSeq.pm!", 6 if $@;
}
