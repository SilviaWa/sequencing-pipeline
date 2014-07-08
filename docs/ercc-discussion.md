## ERCC Discussion with Scott Schwartz from Borlaug

Just copied directly in here with no editing:

Subject: Re: ERCC Bleeding
From: Jason <Jason@JasonKnight.us>
To: Scott Schwartz <sschwartz@ag.tamu.edu>
Cc: "Jennifer S. Goldsby" <jsgoldsby@tamu.edu>, "Laurie D. Davidson" <l-davidson@tamu.edu>, 
	Roger Zoh <rszoh8@gmail.com>
Content-Type: multipart/alternative; boundary=90e6ba10a7d5844a4704d4a373c9

--90e6ba10a7d5844a4704d4a373c9
Content-Type: text/plain; charset=ISO-8859-1

Ack! I started replying to your comments and then decided to look closer at
my code and lo and behold: I swapped the 74% number. The new and improved
numbers (with histograms counts!) are:

```
                           Reads         Ratio to total
Equidistant:                6841         0.170
Closer to ERCC-:            3569         0.089
Closer to ERCC+:           29850         0.741
Total 40259

Histogram of minimum ERCC- distances for all reads:
[(1, 919), (2, 7955), (3, 17601), (4, 11463), (5, 2322)]

Histogram of minimum ERCC+ distances for all reads:
[(1, 18140), (2, 10591), (3, 6106), (4, 4140), (5, 1261), (6, 22)]

Histogram of differences (ERCC- - ERCC+) of minimum distances for all
reads:
[(0, 6841), (1, 13490), (2, 10409), (3, 5951), (-1, 1881), (-4, 30), (-3,
387), (-2, 1271)]
```

So 74% of the reads have barcodes that are closer to ERCC+, and 91% are
closer or equidistant to ERCC+! Definitely odd.

At this point, I started thinking that maybe the ERCC+ was 'better'
positioned in the sequence space (using the Levenshtein distance as a
metric) to be 'closer' to more sequences randomly. So I whipped up a brute
force enumeration and found: 23% of 6mers are closer to an ERCC+ barcode
than ERCC-, 42% the other way, and 35% are equidistant. So that doesn't
look like it could explain it.

But regardless, I don't think this changes our conclusions that we're
seeing some wack things with 5 barcodes on a lane using the Truseq kit (not
that that's necessarily an important factor, but it's important to note
nonetheless).

Now to see if 15 barcodes fixes this. :)


On Thu, Jan 31, 2013 at 5:17 PM, Scott Schwartz <sschwartz@ag.tamu.edu>wrote:

>
>
>  Okay, with some quickly borrowed code<http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Levenshtein_distance#Python> and
> some brute force grepping, I've got some numbers:
>
>  nice.
>
>  Out of 40k reads in Undetermined that mapped nearly perfectly to ERCC
> controls (from the 5M 'total'), 919 (2.2%) had a barcode that was only an edit
> distance  <http://en.wikipedia.org/wiki/Levenshtein_distance>of 1 away
> from one of the ERCC negative samples (almost miscalled), and 8k (20%) had
> an edit distance of 2 from one of these samples.
>
>  So -- for sure -- we got bleedthrough... it is definitely conceivable.
>
>  74% (30k/40k) were closer to the ERCC- than the ERCC+ (which is a little
> higher than expected from pure chance considering 3/5 of the samples were
> ERCC-)
>
>  Hmm... don't think the 3/5 is actually the exact expected ratio... I
> mean, there's more to it than just pure chance.
>  74% is just showing us how the error happens. When it's an error, it
> tends to look more like the wrong barcode.
> Indeed, it is strange that the barcodes "in error" "prefer" ERCC-...
> Okay, got it... errors are caused when we've got light/cluster
> contamination (image blur/fuzzyness).   if the contaminating colors are
> from the same barcodes, then there's no contamination for all practical
> purposes.  When there's real contamination, it will look like the things
> causing the contamination... i.e., barcodes other than what it's supposed
> to be... so I think errors would tend towards the other barcodes.
> Not sure if you're buyin'.
> Seems legit to me.
>
>
>  On the flip side, 18k (45%) and 10k (26%) had an edit distance of 1 or 2
> away from one of the ERCC+ samples, so definitely more than the ERCC- group.
>
>   Wait... how does this work with 74% closer to ERCC-?  These
> "closenesses" are still beat by ERCC- sample barcodes 3/4 of the time?
>  This seems to be a mathy weirdness trick.
>
>
>  So... interesting. I'm not quite sure how to interpret all of that,
> other than the error rates seem to definitely be higher in the barcode
> region than further in.
>
>  Yeah... let's not mix such few samples.
> Incidentally, there's something else going on the machine with just 4
> samples.
> We should avoid this if possible.
> Indeed, we can just mix it into other (nicely balanced) lanes.
>
>  Scott
>
>   Scott Schwartz, PhD
> Statistical Geneticist and Bioinformatics Scientist,
> Genomics and Bioinformatics
> Texas AgriLife Research
> Texas A&M System
> Rm 175 - Norman E. Borlaug Center
> College Station, TX 77843-2123
>
>  Email: sschwartz@ag.tamu.edu
> Office: (979) 845-1068
> Cell: (210) 296-4392
> Website: http://www.txgen.tamu.edu<https://agrilifepeople.tamu.edu/index.cfm/event/publicDirectory/WhichEntity/3/whichunit/425/>
>    ------------------------------
> *From:* binarybana@gmail.com [binarybana@gmail.com] on behalf of Jason
> [Jason@JasonKnight.us]
> *Sent:* Wednesday, January 30, 2013 9:47 PM
> *To:* Scott Schwartz
> *Cc:* Jennifer S. Goldsby; Laurie D. Davidson; Roger Zoh
> *Subject:* Re: ERCC Bleeding
>
>   Okay, with some quickly borrowed code<http://en.wikibooks.org/wiki/Algorithm_implementation/Strings/Levenshtein_distance#Python> and
> some brute force grepping, I've got some numbers:
>
>  Out of 40k reads in Undetermined that mapped nearly perfectly to ERCC
> controls (from the 5M 'total'), 919 (2.2%) had a barcode that was only an edit
> distance <http://en.wikipedia.org/wiki/Levenshtein_distance>of 1 away
> from one of the ERCC negative samples (almost miscalled), and 8k (20%) had
> an edit distance of 2 from one of these samples.
>
>  74% (30k/40k) were closer to the ERCC- than the ERCC+ (which is a little
> higher than expected from pure chance considering 3/5 of the samples were
> ERCC-)
>
>  On the flip side, 18k (45%) and 10k (26%) had an edit distance of 1 or 2
> away from one of the ERCC+ samples, so definitely more than the ERCC- group.
>
>  So... interesting. I'm not quite sure how to interpret all of that,
> other than the error rates seem to definitely be higher in the barcode
> region than further in.
>
>
> On Wed, Jan 30, 2013 at 2:06 PM, Jason <Jason@jasonknight.us> wrote:
>
>>  *For those of you just now being CC'd I've been discussing some ERCC
>> bleedthrough with Scott, see the transcript below for more intro and
>> details.*
>>
>>  Yes, sorry for not being more specific, these were with the passed
>> filter.
>>
>> Spike-in's for the ERCC+ samples were detected at about 2% (640k/31M) and
>> if there are 2 ERCC+ on a lane with 3 ERCC-, then we'd expect to see 2/5 *
>> 0.02 * 5M ... 40k, so we're right on the money!
>>
>>  Do you know what the approximate sequencing error rate of the 2500? I
>> guess it doesn't much matter in this case, because we're looking at the
>> barcode area, which could see much higher error rates. Indeed, for one
>> ERCC- sample, we see 314 ERCC reads with avg mapped length of 99.36 bp with
>> a mismatch rate of 1.03%. So it looks like the error rates would have to be
>> much higher in the barcode region (to completely 'flip' the barcode) and
>> still give us 100 mapped reads.
>>
>>  Yikes.
>>
>>  Here's to hoping that 15+ barcodes will clear this mess up.
>>
>>
>> On Wed, Jan 30, 2013 at 1:43 PM, Scott Schwartz <sschwartz@ag.tamu.edu>wrote:
>>
>>>  Hey Jason -- We break the undetermined reads into 3 sets: passed
>>> filter, prefiltered, with passed filter w/ adapter.
>>>
>>>  I think you probably used the passed filter... the fastq file that
>>> doesn't say prefiltered or adapter.
>>> In this case, these reads are fine as far as illumina is concerned.
>>> However, they don't have the right barcode.
>>> As far as I know, this should be sequencing error... (eek if otherwise)
>>> So... if barcodes can come out with the wrong sequence by error (indeed
>>> you see this), then they could also likely hop into other samples just as
>>> these changed to look like no expected barcode.
>>>
>>>  Based on what you've seen, I think you have bleed through, and I think
>>> it's at the rate you've seen betwixt your samples. (order 10^3 or so).
>>>
>>>  40k/5M... hmm... is that the level the spike-ins were used at?
>>>
>>>  I wouldn't bother with a detailed barcode distance analysis unless
>>> you're in the mood.
>>> All you will learn about is what the sequencing error looks like...
>>> which I don't think helps.
>>> I think the observed contam rate is what's important.
>>>
>>>  Scott
>>>
>>>
>>>
>>>   Scott Schwartz, PhD
>>> Statistical Geneticist and Bioinformatics Scientist,
>>> Genomics and Bioinformatics
>>> Texas AgriLife Research
>>> Texas A&M System
>>> Rm 175 - Norman E. Borlaug Center
>>> College Station, TX 77843-2123
>>>
>>>  Email: sschwartz@ag.tamu.edu
>>> Office: (979) 845-1068
>>> Cell: (210) 296-4392
>>> Website: http://www.txgen.tamu.edu<https://agrilifepeople.tamu.edu/index.cfm/event/publicDirectory/WhichEntity/3/whichunit/425/>
>>>    ------------------------------
>>>  *From:* binarybana@gmail.com [binarybana@gmail.com] on behalf of Jason
>>> [Jason@JasonKnight.us]
>>>  *Sent:* Wednesday, January 30, 2013 1:24 PM
>>>
>>> *To:* Scott Schwartz
>>> *Subject:* Re: ERCC Bleeding
>>>
>>>    Scott,
>>>
>>>  Well, there are lots of ERCC reads in Undetermined: both lanes 1 and 2
>>> have around 40k reads ERCC out of 5M reads, with almost all of those
>>> mappings being all 100bp. I don't think this is surprising though, as these
>>> could easily be coming from the samples with the ERCC spike-ins in them.
>>>
>>>  I think to make a meaningful comparison, we really have to look at the
>>> other multiplexed samples, as we are interested in the probability of a
>>> barcode being called incorrectly, and looking at the reads which Illumina
>>> admits to not being able to reliably call does not help us there.
>>>
>>>  I thought about looking at the reads that mapped to ERCC in
>>> Undetermined, and looking at Levenshtein distances of the barcode to the
>>> barcodes of the non ERCC plots, to try and get a handle on how 'close'
>>> Illumina was to miscalling these reads barcodes, but I'm not sure I have
>>> the time for that.
>>>
>>>  So unfortunately, we're still left with the possibility of this
>>> bleedthrough. I'm thinking we might need to do a run with >14 barcodes to
>>> see if the problem goes away, as otherwise I don't see a way at learning
>>> more from the data we have. Unless you have another idea?
>>>
>>>  Jason
>>>
>>>
>>> On Wed, Jan 30, 2013 at 10:32 AM, Jason <Jason@jasonknight.us> wrote:
>>>
>>>> Analysis running, I'll let you know what I find.
>>>>
>>>>  Thanks,
>>>> Jason
>>>>
>>>>
>>>> On Tue, Jan 29, 2013 at 3:54 PM, Scott Schwartz <sschwartz@ag.tamu.edu>wrote:
>>>>
>>>>>  Okay -- Actually, you should have "Undetermined" reads from those
>>>>> two initial lanes already.
>>>>>
>>>>>  Hmm... things are not as simple as I first though for the lane 5
>>>>> thing... at this point I would have to give you EVERYTHING not Chapkin
>>>>> barcoded... which would be all the other project (!). (we just do multiple
>>>>> passes when there are multiple projects in a lane).  I do trust that you
>>>>> wouldn't do any evil with it, but I'm still kind of uncomfortable releasing
>>>>> everything that way...
>>>>>
>>>>>  Let's start with the undemuxed you have -- sorry to change my mind
>>>>> here -- but I think that should tell you everything you need to know in
>>>>> terms of this little mystery.
>>>>>
>>>>>  If you still think you need lane 5 afterwords, let me know and I'll
>>>>> run it by boss charlie and we'll see from there.
>>>>>
>>>>> Scott
>>>>>
>>>>>   Scott Schwartz, PhD
>>>>> Statistical Geneticist and Bioinformatics Scientist,
>>>>> Genomics and Bioinformatics
>>>>> Texas AgriLife Research
>>>>> Texas A&M System
>>>>> Rm 175 - Norman E. Borlaug Center
>>>>> College Station, TX 77843-2123
>>>>>
>>>>>  Email: sschwartz@ag.tamu.edu
>>>>> Office: (979) 845-1068
>>>>> Cell: (210) 296-4392
>>>>> Website: http://www.txgen.tamu.edu<https://agrilifepeople.tamu.edu/index.cfm/event/publicDirectory/WhichEntity/3/whichunit/425/>
>>>>>    ------------------------------
>>>>>  *From:* binarybana@gmail.com [binarybana@gmail.com] on behalf of
>>>>> Jason [Jason@JasonKnight.us]
>>>>>  *Sent:* Tuesday, January 29, 2013 3:24 PM
>>>>> *To:* Scott Schwartz
>>>>> *Subject:* Re: ERCC Bleeding
>>>>>
>>>>>    That sounds great! Could we also get the "undemultiplexed" file
>>>>> for our first two lanes?
>>>>>
>>>>>  I promise not to use these files for evil. :) Just let me know if
>>>>> you want an SFTP account to push them to, or whatever would be easiest for
>>>>> you.
>>>>>
>>>>>  Jason
>>>>>
>>>>>
>>>>> On Tue, Jan 29, 2013 at 1:58 PM, Scott Schwartz <sschwartz@ag.tamu.edu
>>>>> > wrote:
>>>>>
>>>>>>  Hi Jason -- Here's what we can do.
>>>>>>
>>>>>>  The other samples in the lane were a different type of setup where
>>>>>> essentially 18 bases had to match for barcoding purposes, so, I think it's
>>>>>> pretty unlikely ERCC data ended up there. In that case, they would have
>>>>>> ended up in our so called "Undemultiplexed" read file.  You shouldn't have
>>>>>> gotten this file, as it's not clear who the reads belongs too.  However, as
>>>>>> this is indeed an intriguing issue, what I'd like to do is get you that
>>>>>> file, and have you look for ERCC's, and see what barcodes they came with.
>>>>>>  If indeed you find ERCC's in the undetermined file, and they have wak
>>>>>> looking barcodes (you know, that look like sequence read errors), then I
>>>>>> think the problem is sorted out... indeed barcode bleeding to some degree
>>>>>> (eek).  The good news is that the bleeding seems minimal, and does
>>>>>> establish a threshold by for being skeptical in terms of detection.
>>>>>>
>>>>>>  Hopefully this will be suitable for your purposes?
>>>>>>
>>>>>>  If yes, and you agree to not use the Undetermined data for evil, I
>>>>>> can get that over to you pretty easily.
>>>>>>
>>>>>>  Scott
>>>>>>
>>>>>>
>>>>>>
>>>>>>     Scott Schwartz, PhD
>>>>>> Statistical Geneticist and Bioinformatics Scientist,
>>>>>> Genomics and Bioinformatics
>>>>>> Texas AgriLife Research
>>>>>> Texas A&M System
>>>>>> Rm 175 - Norman E. Borlaug Center
>>>>>> College Station, TX 77843-2123
>>>>>>
>>>>>>  Email: sschwartz@ag.tamu.edu
>>>>>> Office: (979) 845-1068
>>>>>> Cell: (210) 296-4392
>>>>>> Website: http://www.txgen.tamu.edu<https://agrilifepeople.tamu.edu/index.cfm/event/publicDirectory/WhichEntity/3/whichunit/425/>
>>>>>>    ------------------------------
>>>>>> *From:* binarybana@gmail.com [binarybana@gmail.com] on behalf of
>>>>>> Jason [Jason@JasonKnight.us]
>>>>>> *Sent:* Monday, January 28, 2013 10:08 AM
>>>>>> *To:* Scott Schwartz
>>>>>> *Subject:* ERCC Bleeding
>>>>>>
>>>>>>    Hey Scott,
>>>>>>
>>>>>>  We just had a crazy idea to better address the issue of ERCC
>>>>>> 'bleedthrough' or incorrect barcoding: on the second run of sequencing that
>>>>>> you did for our human fecal samples (Denaturation, and RNALater) where it
>>>>>> was combined with other samples on the lane, is there any way you could
>>>>>> check those other samples and see if there are detected ERCC transcripts in
>>>>>> those?
>>>>>>
>>>>>>  That would be pretty telling for bleedthrough as those samples are
>>>>>> generated in other labs. We would do this ourselves, but we don't have
>>>>>> access to the other samples.
>>>>>>
>>>>>>  Let me know what you think, I can give you the short python code to
>>>>>> generate the plots I showed you, and here is a link to the various files
>>>>>> for the Ambion ERCC kit
>>>>>> http://products.invitrogen.com/ivgn/product/4456740 (go down to
>>>>>> documents for the .fa, .gtf, and concentrations).
>>>>>>
>>>>>>  Jason
>>>>>>
>>>>>
>>>>>
>>>>
>>>
>>
>

--90e6ba10a7d5844a4704d4a373c9
Content-Type: text/html; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr">Ack! I started replying to your comments and then decided =
to look closer at my code and lo and behold: I swapped the 74% number. The =
new and improved numbers (with histograms counts!) are:<div><br></div><div>
<div><font face=3D"courier new, monospace">=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0Reads =A0 =A0 =A0 =A0 Ratio to total</font></div><di=
v><font face=3D"courier new, monospace">Equidistant: =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A06841 =A0 =A0 =A0 =A0 0.170</font></div><div><font face=3D"courie=
r new, monospace">Closer to ERCC-: =A0 =A0 =A0 =A0 =A0 =A03569 =A0 =A0 =A0 =
=A0 0.089</font></div>
<div><font face=3D"courier new, monospace">Closer to ERCC+: =A0 =A0 =A0 =A0=
 =A0 29850 =A0 =A0 =A0 =A0 0.741</font></div><div><font face=3D"courier new=
, monospace">Total 40259</font></div><div><font face=3D"courier new, monosp=
ace"><br></font></div>
<div><font face=3D"courier new, monospace">Histogram of minimum ERCC- dista=
nces for all reads:=A0</font></div><div><font face=3D"courier new, monospac=
e">[(1, 919), (2, 7955), (3, 17601), (4, 11463), (5, 2322)]</font></div><di=
v>
<font face=3D"courier new, monospace"><br></font></div><div><font face=3D"c=
ourier new, monospace">Histogram of minimum ERCC+ distances for all reads:=
=A0</font></div><div><font face=3D"courier new, monospace">[(1, 18140), (2,=
 10591), (3, 6106), (4, 4140), (5, 1261), (6, 22)]</font></div>
<div><font face=3D"courier new, monospace"><br></font></div><div><font face=
=3D"courier new, monospace">Histogram of differences (ERCC- - ERCC+) of min=
imum distances for all reads:=A0</font></div><div><font face=3D"courier new=
, monospace">[(0, 6841), (1, 13490), (2, 10409), (3, 5951), (-1, 1881), (-4=
, 30), (-3, 387), (-2, 1271)]</font></div>
<div><br></div><div>So 74% of the reads have barcodes that are closer to ER=
CC+, and 91% are closer or=A0equidistant=A0to ERCC+! Definitely odd.</div><=
div><br></div><div>At this point, I started thinking that maybe the ERCC+ w=
as &#39;better&#39; positioned in the sequence space (using the Levenshtein=
 distance as a metric) to be &#39;closer&#39; to more sequences randomly. S=
o I whipped up a brute force enumeration and found: 23% of 6mers are closer=
 to an ERCC+ barcode than ERCC-, 42% the other way, and 35% are equidistant=
. So that doesn&#39;t look like it could explain it.</div>
<div><br></div><div>But regardless, I don&#39;t think this changes our conc=
lusions that we&#39;re seeing some wack things with 5 barcodes on a lane us=
ing the Truseq kit (not that that&#39;s necessarily an important factor, bu=
t it&#39;s important to note nonetheless).</div>
</div><div><br></div><div style>Now to see if 15 barcodes fixes this. :)</d=
iv></div><div class=3D"gmail_extra"><br><br><div class=3D"gmail_quote">On T=
hu, Jan 31, 2013 at 5:17 PM, Scott Schwartz <span dir=3D"ltr">&lt;<a href=
=3D"mailto:sschwartz@ag.tamu.edu" target=3D"_blank">sschwartz@ag.tamu.edu</=
a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">




<div>
<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma">
<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma">
<div><br>
</div>
<div><br>
</div>
<span style=3D"font-family:&#39;Times New Roman&#39;;font-size:16px">
<div dir=3D"ltr"><div class=3D"im"><font color=3D"#ff0000">Okay, with some=
=A0<a href=3D"http://en.wikibooks.org/wiki/Algorithm_implementation/Strings=
/Levenshtein_distance#Python" target=3D"_blank">quickly borrowed code</a>=
=A0and some brute force grepping, I&#39;ve got
 some numbers:</font>
<div><br>
</div>
</div><div>nice.</div><div class=3D"im">
<div><br>
</div>
<div><font color=3D"#ff0000">Out of 40k reads in Undetermined that mapped n=
early perfectly to ERCC controls (from the 5M &#39;total&#39;), 919 (2.2%) =
had a barcode that was only an=A0<a href=3D"http://en.wikipedia.org/wiki/Le=
venshtein_distance" target=3D"_blank">edit
 distance=A0</a>of 1 away from one of the ERCC negative samples (almost mis=
called), and 8k (20%) had an edit distance of 2 from one of these samples.<=
/font></div>
<div><br>
</div>
</div><div>So -- for sure -- we got bleedthrough... it is definitely concei=
vable.=A0</div><div class=3D"im">
<div><br>
</div>
<div><font color=3D"#ff0000">74% (30k/40k) were closer to the ERCC- than th=
e ERCC+ (which is a little higher than expected from pure chance considerin=
g 3/5 of the samples were ERCC-)</font></div>
<div><br>
</div>
</div><div>Hmm... don&#39;t think the 3/5 is actually the exact expected ra=
tio... I mean, there&#39;s more to it than just pure chance. =A0</div>
</div>
</span><span style=3D"font-family:&#39;Times New Roman&#39;;font-size:16px"=
>74% is just showing us how the error happens. When it&#39;s an error, it t=
ends to look more like the wrong barcode. =A0</span></div>
<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma"><span style=
=3D"font-family:&#39;Times New Roman&#39;;font-size:16px">Indeed, it is str=
ange that the barcodes &quot;in error&quot; &quot;prefer&quot; ERCC-...</sp=
an></div>

<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma"><span style=
=3D"font-family:&#39;Times New Roman&#39;;font-size:16px">Okay, got it... e=
rrors are caused when we&#39;ve got light/cluster contamination (image blur=
/fuzzyness).
 =A0 if the contaminating colors are from the same barcodes, then there&#39=
;s no contamination for all practical purposes. =A0When there&#39;s real co=
ntamination, it will look like the things causing the contamination... i.e.=
, barcodes other than what it&#39;s supposed to
 be... so I think errors would tend towards the other barcodes.</span></div=
>
<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma"><span style=
=3D"font-family:&#39;Times New Roman&#39;;font-size:16px">Not sure if you&#=
39;re buyin&#39;.</span></div>
<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma"><span style=
=3D"font-family:&#39;Times New Roman&#39;;font-size:16px">Seems legit to me=
. =A0</span></div>
<div style=3D"direction:ltr"><div class=3D"im"><span style=3D"font-size:16p=
x;font-family:&#39;Times New Roman&#39;">
<div dir=3D"ltr">
<div><br>
</div>
<div><br>
</div>
<div><font color=3D"#ff0000">On the flip side, 18k (45%) and 10k (26%) had =
an edit distance of 1 or 2 away from one of the ERCC+ samples, so definitel=
y more than the ERCC- group.</font></div>
<div><br>
</div>
</div>
</span></div><span style=3D"font-family:&#39;Times New Roman&#39;;font-size=
:16px">
<div>Wait... how does this work with 74% closer to ERCC-? =A0These &quot;cl=
osenesses&quot; are still beat by ERCC- sample barcodes 3/4 of the time? =
=A0This seems to be a mathy weirdness trick.</div>
<div style><br>
</div>
</span><span style=3D"font-family:&#39;Times New Roman&#39;;font-size:16px"=
><div class=3D"im">
<div dir=3D"ltr">
<div style><br>
</div>
<div><font color=3D"#ff0000">So... interesting. I&#39;m not quite sure how =
to interpret all of that, other than the error rates seem to definitely be =
higher in the barcode region than further in.=A0</font></div>
</div>
<div class=3D"gmail_extra" style><br>
</div>
</div><div class=3D"gmail_extra" style>Yeah... let&#39;s not mix such few s=
amples.
</div>
<div class=3D"gmail_extra" style>Incidentally, there&#39;s something else g=
oing on the machine with just 4 samples. =A0</div>
<div class=3D"gmail_extra" style>We should avoid this if possible.=A0</div>
<div class=3D"gmail_extra" style>Indeed, we can just mix it into other (nic=
ely balanced) lanes.=A0</div>
<div class=3D"gmail_extra" style><br>
</div>
<div class=3D"gmail_extra" style>Scott</div>
</span><div class=3D"im">
<div style=3D"font-size:10pt;font-family:Tahoma"><br>
<div style=3D"font-family:Tahoma;font-size:13px">
<div style=3D"font-family:Tahoma;font-size:13px">
<div style=3D"font-family:Tahoma;font-size:13px">
<div>Scott Schwartz, PhD</div>
<div>Statistical Geneticist and Bioinformatics Scientist,=A0</div>
<div>Genomics and Bioinformatics</div>
<div>Texas AgriLife Research</div>
<div>Texas A&amp;M System</div>
<div>Rm 175 - Norman E. Borlaug Center</div>
<div>College Station, TX 77843-2123</div>
<div><br>
</div>
<div>Email: <a href=3D"mailto:sschwartz@ag.tamu.edu" target=3D"_blank">ssch=
wartz@ag.tamu.edu</a></div>
<div>Office: <a href=3D"tel:%28979%29%20845-1068" value=3D"+19798451068" ta=
rget=3D"_blank">(979) 845-1068</a></div>
<div>Cell: <a href=3D"tel:%28210%29%20296-4392" value=3D"+12102964392" targ=
et=3D"_blank">(210) 296-4392</a></div>
<div>Website: <a href=3D"https://agrilifepeople.tamu.edu/index.cfm/event/pu=
blicDirectory/WhichEntity/3/whichunit/425/" target=3D"_blank">
http://www.txgen.tamu.edu</a></div>
</div>
</div>
</div>
</div>
</div><div style=3D"font-size:16px;font-family:&#39;Times New Roman&#39;">
<hr>
<div style=3D"direction:ltr"><font face=3D"Tahoma" color=3D"#000000"><div c=
lass=3D"im"><b>From:</b> <a href=3D"mailto:binarybana@gmail.com" target=3D"=
_blank">binarybana@gmail.com</a> [<a href=3D"mailto:binarybana@gmail.com" t=
arget=3D"_blank">binarybana@gmail.com</a>] on behalf of Jason [Jason@JasonK=
night.us]<br>

</div><b>Sent:</b> Wednesday, January 30, 2013 9:47 PM<br>
<b>To:</b> Scott Schwartz<br>
<b>Cc:</b> Jennifer S. Goldsby; Laurie D. Davidson; Roger Zoh<br>
<b>Subject:</b> Re: ERCC Bleeding<br>
</font><br>
</div><div><div class=3D"h5">
<div></div>
<div>
<div dir=3D"ltr">Okay, with some <a href=3D"http://en.wikibooks.org/wiki/Al=
gorithm_implementation/Strings/Levenshtein_distance#Python" target=3D"_blan=
k">
quickly borrowed code</a>=A0and some brute force grepping, I&#39;ve got som=
e numbers:
<div><br>
</div>
<div>Out of 40k reads in Undetermined that mapped nearly perfectly to ERCC =
controls (from the 5M &#39;total&#39;), 919 (2.2%) had a barcode that was o=
nly an
<a href=3D"http://en.wikipedia.org/wiki/Levenshtein_distance" target=3D"_bl=
ank">edit distance
</a>of 1 away from one of the ERCC negative samples (almost miscalled), and=
 8k (20%) had an edit distance of 2 from one of these samples.</div>
<div><br>
</div>
<div>74% (30k/40k) were closer to the ERCC- than the ERCC+ (which is a litt=
le higher than expected from pure chance considering 3/5 of the samples wer=
e ERCC-)</div>
<div><br>
</div>
<div>On the flip side, 18k (45%) and 10k (26%) had an edit distance of 1 or=
 2 away from one of the ERCC+ samples, so definitely more than the ERCC- gr=
oup.</div>
<div><br>
</div>
<div>So... interesting. I&#39;m not quite sure how to interpret all of that=
, other than the error rates seem to definitely be higher in the barcode re=
gion than further in.=A0</div>
</div>
<div class=3D"gmail_extra"><br>
<br>
<div class=3D"gmail_quote">On Wed, Jan 30, 2013 at 2:06 PM, Jason <span dir=
=3D"ltr">&lt;<a href=3D"mailto:Jason@jasonknight.us" target=3D"_blank">Jaso=
n@jasonknight.us</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<div dir=3D"ltr">
<div><i>For those of you just now being CC&#39;d I&#39;ve been discussing s=
ome ERCC bleedthrough with Scott, see the transcript below for more intro a=
nd details.</i></div>
<div><br>
</div>
Yes, sorry for not being more specific, these were with the passed filter.
<div><br>
<div>Spike-in&#39;s for the ERCC+ samples were detected at about 2% (640k/3=
1M) and if there are 2 ERCC+ on a lane with 3 ERCC-, then we&#39;d expect t=
o see 2/5 * 0.02 * 5M ... 40k, so we&#39;re right on the money!</div>
<div><br>
</div>
<div>Do you know what the approximate sequencing error rate of the 2500? I =
guess it doesn&#39;t much matter in this case, because we&#39;re looking at=
 the barcode area, which could see much higher error rates. Indeed, for one=
 ERCC- sample, we see 314 ERCC reads with
 avg mapped length of 99.36 bp with a mismatch rate of 1.03%. So it looks l=
ike the error rates would have to be much higher in the barcode region (to =
completely &#39;flip&#39; the barcode) and still give us 100 mapped reads.<=
/div>

<div><br>
</div>
<div>Yikes.</div>
<div><br>
</div>
<div>Here&#39;s to hoping that 15+ barcodes will clear this mess up.</div>
</div>
</div>
<div>
<div>
<div class=3D"gmail_extra"><br>
<br>
<div class=3D"gmail_quote">On Wed, Jan 30, 2013 at 1:43 PM, Scott Schwartz =
<span dir=3D"ltr">
&lt;<a href=3D"mailto:sschwartz@ag.tamu.edu" target=3D"_blank">sschwartz@ag=
.tamu.edu</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<div>
<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma">Hey Jason --=
 We break the undetermined reads into 3 sets: passed filter, prefiltered, w=
ith passed filter w/ adapter.=A0
<div><br>
</div>
<div>I think you probably used the passed filter... the fastq file that doe=
sn&#39;t say prefiltered or adapter.=A0</div>
<div>In this case, these reads are fine as far as illumina is concerned.</d=
iv>
<div>However, they don&#39;t have the right barcode. =A0</div>
<div>As far as I know, this should be sequencing error... (eek if otherwise=
)</div>
<div>So... if barcodes can come out with the wrong sequence by error (indee=
d you see this), then they could also likely hop into other samples just as=
 these changed to look like no expected barcode. =A0</div>
<div><br>
</div>
<div>Based on what you&#39;ve seen, I think you have bleed through, and I t=
hink it&#39;s at the rate you&#39;ve seen betwixt your samples. (order 10^3=
 or so).=A0</div>
<div><br>
</div>
<div>40k/5M... hmm... is that the level the spike-ins were used at?</div>
<div><br>
</div>
<div>I wouldn&#39;t bother with a detailed barcode distance analysis unless=
 you&#39;re in the mood.</div>
<div>All you will learn about is what the sequencing error looks like... wh=
ich I don&#39;t think helps.</div>
<div>I think the observed contam rate is what&#39;s important. =A0</div>
<div><br>
</div>
<div>Scott</div>
<div><br>
</div>
<div>
<div><br>
<div><br>
<div style=3D"font-family:Tahoma;font-size:13px">
<div style=3D"font-family:Tahoma;font-size:13px">
<div style=3D"font-family:Tahoma;font-size:13px">
<div>Scott Schwartz, PhD</div>
<div>Statistical Geneticist and Bioinformatics Scientist,=A0</div>
<div>Genomics and Bioinformatics</div>
<div>Texas AgriLife Research</div>
<div>Texas A&amp;M System</div>
<div>Rm 175 - Norman E. Borlaug Center</div>
<div>College Station, TX 77843-2123</div>
<div><br>
</div>
<div>Email: <a href=3D"mailto:sschwartz@ag.tamu.edu" target=3D"_blank">ssch=
wartz@ag.tamu.edu</a></div>
<div>Office: <a href=3D"tel:%28979%29%20845-1068" value=3D"+19798451068" ta=
rget=3D"_blank">
(979) 845-1068</a></div>
<div>Cell: <a href=3D"tel:%28210%29%20296-4392" value=3D"+12102964392" targ=
et=3D"_blank">
(210) 296-4392</a></div>
<div>Website: <a href=3D"https://agrilifepeople.tamu.edu/index.cfm/event/pu=
blicDirectory/WhichEntity/3/whichunit/425/" target=3D"_blank">
http://www.txgen.tamu.edu</a></div>
</div>
</div>
</div>
</div>
</div>
<div style=3D"font-size:16px;font-family:Times New Roman">
<hr>
<div style=3D"direction:ltr"><font face=3D"Tahoma" color=3D"#000000">
<div><b>From:</b> <a href=3D"mailto:binarybana@gmail.com" target=3D"_blank"=
>binarybana@gmail.com</a> [<a href=3D"mailto:binarybana@gmail.com" target=
=3D"_blank">binarybana@gmail.com</a>] on behalf of Jason [Jason@JasonKnight=
.us]<br>

</div>
<b>Sent:</b> Wednesday, January 30, 2013 1:24 PM
<div>
<div><br>
<b>To:</b> Scott Schwartz<br>
<b>Subject:</b> Re: ERCC Bleeding<br>
</div>
</div>
</font><br>
</div>
<div>
<div>
<div></div>
<div>
<div dir=3D"ltr">Scott,
<div><br>
</div>
<div>Well, there are lots of ERCC reads in Undetermined: both lanes 1 and 2=
 have around 40k reads ERCC out of 5M reads, with almost all of those mappi=
ngs being all 100bp. I don&#39;t think this is surprising though, as these =
could easily be coming from the samples
 with the ERCC spike-ins in them.=A0</div>
<div><br>
</div>
<div>I think to make a meaningful comparison, we really have to look at the=
 other multiplexed samples, as we are interested in the probability of a ba=
rcode being called incorrectly, and looking at the reads which Illumina adm=
its to not being able to reliably
 call does not help us there.</div>
<div><br>
</div>
<div>I thought about looking at the reads that mapped to ERCC in Undetermin=
ed, and looking at Levenshtein distances of the barcode to the barcodes of =
the non ERCC plots, to try and get a handle on how &#39;close&#39; Illumina=
 was to miscalling these reads barcodes,
 but I&#39;m not sure I have the time for that.</div>
<div><br>
</div>
<div>So unfortunately, we&#39;re still left with the possibility of this bl=
eedthrough. I&#39;m thinking we might need to do a run with &gt;14 barcodes=
 to see if the problem goes away, as otherwise I don&#39;t see a way at lea=
rning more from the data we have. Unless you have
 another idea?</div>
<div><br>
</div>
<div>Jason</div>
</div>
<div class=3D"gmail_extra"><br>
<br>
<div class=3D"gmail_quote">On Wed, Jan 30, 2013 at 10:32 AM, Jason <span di=
r=3D"ltr">
&lt;<a href=3D"mailto:Jason@jasonknight.us" target=3D"_blank">Jason@jasonkn=
ight.us</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<div dir=3D"ltr">Analysis running, I&#39;ll let you know what I find.
<div><br>
</div>
<div>Thanks,</div>
<div>Jason</div>
</div>
<div>
<div>
<div class=3D"gmail_extra"><br>
<br>
<div class=3D"gmail_quote">On Tue, Jan 29, 2013 at 3:54 PM, Scott Schwartz =
<span dir=3D"ltr">
&lt;<a href=3D"mailto:sschwartz@ag.tamu.edu" target=3D"_blank">sschwartz@ag=
.tamu.edu</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<div>
<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma">Okay -- Actu=
ally, you should have &quot;Undetermined&quot; reads from those two initial=
 lanes already.
<div><br>
</div>
<div>Hmm... things are not as simple as I first though for the lane 5 thing=
... at this point I would have to give you EVERYTHING not=A0Chapkin barcode=
d... which would be all the other project (!). (we just do multiple passes =
when there are multiple projects in
 a lane). =A0I do trust that you wouldn&#39;t do any evil with it, but I&#3=
9;m still kind of uncomfortable releasing everything that way...</div>
<div><br>
</div>
<div>Let&#39;s start with the undemuxed you have -- sorry to change my mind=
 here -- but I think that should tell you everything you need to know in te=
rms of this little mystery. =A0</div>
<div><br>
</div>
<div>If you still think you need lane 5 afterwords, let me know and I&#39;l=
l run it by boss charlie and we&#39;ll see from there.<br>
<div><br>
<div>Scott</div>
<div>
<div>
<div><br>
<div style=3D"font-family:Tahoma;font-size:13px">
<div style=3D"font-family:Tahoma;font-size:13px">
<div style=3D"font-family:Tahoma;font-size:13px">
<div>Scott Schwartz, PhD</div>
<div>Statistical Geneticist and Bioinformatics Scientist,=A0</div>
<div>Genomics and Bioinformatics</div>
<div>Texas AgriLife Research</div>
<div>Texas A&amp;M System</div>
<div>Rm 175 - Norman E. Borlaug Center</div>
<div>College Station, TX 77843-2123</div>
<div><br>
</div>
<div>Email: <a href=3D"mailto:sschwartz@ag.tamu.edu" target=3D"_blank">ssch=
wartz@ag.tamu.edu</a></div>
<div>Office: <a href=3D"tel:%28979%29%20845-1068" value=3D"+19798451068" ta=
rget=3D"_blank">
(979) 845-1068</a></div>
<div>Cell: <a href=3D"tel:%28210%29%20296-4392" value=3D"+12102964392" targ=
et=3D"_blank">
(210) 296-4392</a></div>
<div>Website: <a href=3D"https://agrilifepeople.tamu.edu/index.cfm/event/pu=
blicDirectory/WhichEntity/3/whichunit/425/" target=3D"_blank">
http://www.txgen.tamu.edu</a></div>
</div>
</div>
</div>
</div>
</div>
<div style=3D"font-size:16px;font-family:Times New Roman">
<hr>
<div style=3D"direction:ltr"><font face=3D"Tahoma" color=3D"#000000">
<div><b>From:</b> <a href=3D"mailto:binarybana@gmail.com" target=3D"_blank"=
>binarybana@gmail.com</a> [<a href=3D"mailto:binarybana@gmail.com" target=
=3D"_blank">binarybana@gmail.com</a>] on behalf of Jason [Jason@JasonKnight=
.us]<br>

</div>
<b>Sent:</b> Tuesday, January 29, 2013 3:24 PM<br>
<b>To:</b> Scott Schwartz<br>
<b>Subject:</b> Re: ERCC Bleeding<br>
</font><br>
</div>
<div>
<div>
<div></div>
<div>
<div dir=3D"ltr">That sounds great! Could we also get the &quot;undemultipl=
exed&quot; file for our first two lanes?
<div><br>
</div>
<div>I promise not to use these files for evil. :) Just let me know if you =
want an SFTP account to push them to, or whatever would be easiest for you.=
</div>
<div><br>
</div>
<div>Jason</div>
</div>
<div class=3D"gmail_extra"><br>
<br>
<div class=3D"gmail_quote">On Tue, Jan 29, 2013 at 1:58 PM, Scott Schwartz =
<span dir=3D"ltr">
&lt;<a href=3D"mailto:sschwartz@ag.tamu.edu" target=3D"_blank">sschwartz@ag=
.tamu.edu</a>&gt;</span> wrote:<br>
<blockquote class=3D"gmail_quote" style=3D"margin:0 0 0 .8ex;border-left:1p=
x #ccc solid;padding-left:1ex">
<div>
<div style=3D"direction:ltr;font-size:10pt;font-family:Tahoma">Hi Jason -- =
Here&#39;s what we can do.
<div><br>
</div>
<div>The other samples in the lane were a different type of setup where ess=
entially 18 bases had to match for barcoding purposes, so, I think it&#39;s=
 pretty unlikely ERCC data ended up there. In that case, they would have en=
ded up in our so called &quot;Undemultiplexed&quot;
 read file. =A0You shouldn&#39;t have gotten this file, as it&#39;s not cle=
ar who the reads belongs too. =A0However, as this is indeed an intriguing i=
ssue, what I&#39;d like to do is get you that file, and have you look for E=
RCC&#39;s, and see what barcodes they came with. =A0If
 indeed you find ERCC&#39;s in the undetermined file, and they have wak loo=
king barcodes (you know, that look like sequence read errors), then I think=
 the problem is sorted out... indeed barcode bleeding to some degree (eek).=
 =A0The good news is that the bleeding
 seems minimal, and does establish a threshold by for being skeptical in te=
rms of detection. =A0</div>
<div><br>
</div>
<div>Hopefully this will be suitable for your purposes?</div>
<div><br>
</div>
<div>If yes, and you agree to not use the Undetermined data for evil, I can=
 get that over to you pretty easily.=A0</div>
<div><br>
</div>
<div>Scott</div>
<div><br>
</div>
<div><br>
</div>
<div><br>
</div>
<div>
<div>
<div>
<div style=3D"font-family:Tahoma;font-size:13px">
<div style=3D"font-family:Tahoma;font-size:13px">
<div style=3D"font-family:Tahoma;font-size:13px">
<div>Scott Schwartz, PhD</div>
<div>Statistical Geneticist and Bioinformatics Scientist,=A0</div>
<div>Genomics and Bioinformatics</div>
<div>Texas AgriLife Research</div>
<div>Texas A&amp;M System</div>
<div>Rm 175 - Norman E. Borlaug Center</div>
<div>College Station, TX 77843-2123</div>
<div><br>
</div>
<div>Email: <a href=3D"mailto:sschwartz@ag.tamu.edu" target=3D"_blank">ssch=
wartz@ag.tamu.edu</a></div>
<div>Office: <a href=3D"tel:%28979%29%20845-1068" value=3D"+19798451068" ta=
rget=3D"_blank">
(979) 845-1068</a></div>
<div>Cell: <a href=3D"tel:%28210%29%20296-4392" value=3D"+12102964392" targ=
et=3D"_blank">
(210) 296-4392</a></div>
<div>Website: <a href=3D"https://agrilifepeople.tamu.edu/index.cfm/event/pu=
blicDirectory/WhichEntity/3/whichunit/425/" target=3D"_blank">
http://www.txgen.tamu.edu</a></div>
</div>
</div>
</div>
</div>
<div style=3D"font-size:16px;font-family:Times New Roman">
<hr>
<div style=3D"direction:ltr"><font face=3D"Tahoma" color=3D"#000000"><b>Fro=
m:</b> <a href=3D"mailto:binarybana@gmail.com" target=3D"_blank">
binarybana@gmail.com</a> [<a href=3D"mailto:binarybana@gmail.com" target=3D=
"_blank">binarybana@gmail.com</a>] on behalf of Jason [Jason@JasonKnight.us=
]<br>
<b>Sent:</b> Monday, January 28, 2013 10:08 AM<br>
<b>To:</b> Scott Schwartz<br>
<b>Subject:</b> ERCC Bleeding<br>
</font><br>
</div>
<div>
<div>
<div></div>
<div>
<div dir=3D"ltr">Hey Scott,
<div><br>
</div>
<div>We just had a crazy idea to better address the issue of ERCC &#39;blee=
dthrough&#39; or incorrect barcoding: on the second run of sequencing that =
you did for our human fecal samples (Denaturation, and RNALater) where it w=
as combined with other samples on the lane,
 is there any way you could check those other samples and see if there are =
detected ERCC transcripts in those?=A0</div>
<div><br>
</div>
<div>That would be pretty telling for bleedthrough as those samples are gen=
erated in other labs. We would do this ourselves, but we don&#39;t have acc=
ess to the other samples.</div>
<div><br>
</div>
<div>Let me know what you think, I can give you the short python code to ge=
nerate the plots I showed you, and here is a link to the various files for =
the Ambion ERCC kit=A0<a href=3D"http://products.invitrogen.com/ivgn/produc=
t/4456740" target=3D"_blank">http://products.invitrogen.com/ivgn/product/44=
56740</a>=A0(go
 down to documents for the .fa, .gtf, and concentrations).</div>
<div><br>
</div>
<div>Jason</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</blockquote>
</div>
<br>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</blockquote>
</div>
<br>
</div>
</div>
</div>
</blockquote>
</div>
<br>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</div>
</blockquote>
</div>
<br>
</div>
</div>
</div>
</blockquote>
</div>
<br>
</div>
</div>
</div></div></div>
</div>
</div>
</div>

</blockquote></div><br></div>
