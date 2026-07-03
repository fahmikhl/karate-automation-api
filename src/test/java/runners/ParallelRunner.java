package runners;

import com.intuit.karate.Results;
import com.intuit.karate.Runner;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class ParallelRunner {

    @Test
    void run() {
        String tags = System.getProperty("karate.tags", "~@ignore");
        int threads = Integer.parseInt(System.getProperty("karate.threads", "3"));

        Results results = Runner.path("classpath:features")
                .tags(tags)
                .outputCucumberJson(true)
                .parallel(threads);

        assertEquals(0, results.getFailCount(), results.getErrorMessages());
    }
}
