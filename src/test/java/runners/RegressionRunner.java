package runners;

import com.intuit.karate.junit5.Karate;

class RegressionRunner {

    @Karate.Test
    Karate regression() {
        return Karate.run("classpath:features").tags("@regression", "@e2e");
    }
}
