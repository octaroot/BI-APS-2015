<?php

$in = [
[2, 2, 3, 4, 5, 2, 2, 3, 4, 5, 7],
[7, 9, 9, 10, 11, 7, 9, 9, 10, 11, 14],
[13, 14, 16, 16, 17, 13, 14, 16, 16, 17, 21],
[19, 20, 21, 23, 23, 19, 20, 21, 23, 23, 28],
[25, 26, 27, 28, 30, 25, 26, 27, 28, 30, 35],
[9, 11, 13, 11, 15, 12, 12, 13, 14, 15, 71],
[29, 15, 14, 14, 15, 12, 12, 13, 14, 15, 71],
[39, 14, 15, 15, 15, 12, 12, 13, 14, 15, 71],
[49, 13, 16, 18, 15, 12, 12, 13, 14, 15, 71],
[59, 12, 17, 19, 15, 12, 12, 13, 14, 15, 71],
];

$N = 10;

for ($k = 0; $k < $N - 1; $k++)
{
	for ($i = $k + 1; $i < $N; $i++)
	{
		if ( $in[$k][$k] == 0) die ("division by zero [$k row]\n");
		$ratio = $in[$i][$k] / $in[$k][$k];
		for ($j = 0; $j < $N + 1; $j++)
		{
			$in[$i][$j] -= ($in[$k][$j] * $ratio);
		}
	}
}


for ($i = 0; $i < $N; $i++)
{
	for ($j = 0; $j < $N + 1; $j++)
		echo round($in[$i][$j], 5) . "\t";
	echo "\n";
}
