<?php

declare(strict_types=1);

final class SampleClass
{
    public function simpleMethod(): int
    {
        return 1;
    }

    public function complexMethod(int $a, int $b, bool $flag): int
    {
        if ($flag) {
            if ($a > $b) {
                return $a + $b;
            }

            return $a - $b;
        }

        foreach (range(1, $a) as $i) {
            if ($i % 2 === 0) {
                $b += $i;
            }
        }

        return $b;
    }
}
