#!/usr/bin/env perl 
use strict;
use warnings;
use feature 'say';

my $dir = "../data";

# try to open dir

my %samples;

opendir(my $dh, $dir) || die "Diretório $dir não pode ser aberto: $!";

my @inner_dirs = readdir($dh);
for my $s (@inner_dirs){
	# open inner dir and exit loop if not possible
	opendir( my $fh, $dir."/".$s) || next;
	#list of files
	my @q = readdir($fh);
	# filter to get only txt files
	@q = grep { /\.txt$/ } @q;
	# loop file list
	for my $f (@q){
		# create hash with files
		if ($f =~ /(.+)\.txt$/){
			$samples{$1}{$s}="\t$dir"."/".$s."/".$f;
		}
	}
	close $fh;
}
close $dh;

my %cat;
for my $i (keys %samples){
	for my $j (keys %{ $samples{$i}}){
		my %count = get_categories($samples{$i}{$j});
		for my $k (keys %count){
		if ($cat{$i}{$k}){
			$cat{$i}{$k} += $count{$k};
		} else {
			$cat{$i}{$k} = $count{$k};
		}
	}
	}
}

open ( my $output, ">", "../results/contagem.txt") or
die "não foi possível abrir arquivo para salvar resultados em disco";

for my $i (keys %cat){
	for my $k (keys %{ $cat{$i}}){
		print $output ($i, "\t", $k,"\t", $cat{$i}{$k}, "\n");
	}
}
 	

sub get_categories {
	my $file = shift;
	my %categories;
	open (my $fh, $file) || die "Não foi possivel abria arquivo $file: $!";
	while (my $line = <$fh>){
		while ($line =~ /\<([^\>]+)\>/g){
			$categories{$1}++;
		}
	}
	return %categories;
}

#print "categorias\ttotal\n";
#
#for my $i (keys %categories){
#	print ($i, "\t" , $categories{$i}, "\n");
#}
